package com.java.NaniYiMiDa.service.impl;

import com.java.NaniYiMiDa.enumx.ErrorCode;
import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.enumx.RecipeStatus;
import com.java.NaniYiMiDa.enumx.Role;
import com.java.NaniYiMiDa.exception.BusinessException;
import com.java.NaniYiMiDa.po.recipe.Recipe;
import com.java.NaniYiMiDa.po.recipe.RecipeIngredient;
import com.java.NaniYiMiDa.po.recipe.RecipeStep;
import com.java.NaniYiMiDa.po.User;
import com.java.NaniYiMiDa.repository.RecipeIngredientRepository;
import com.java.NaniYiMiDa.repository.RecipeRepository;
import com.java.NaniYiMiDa.service.RecipeService;
import com.java.NaniYiMiDa.service.ingredient.IngredientResolver;
import com.java.NaniYiMiDa.service.search.RecipeMatcher;
import com.java.NaniYiMiDa.tool.SecurityUtil;
import com.java.NaniYiMiDa.vo.recipe.RecipeIngredientVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeStepVO;
import com.java.NaniYiMiDa.vo.recipe.RecipeVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class RecipeServiceImpl implements RecipeService {

	@Autowired
	private RecipeRepository recipeRepository;

	@Autowired
	private RecipeIngredientRepository recipeIngredientRepository;

	@Autowired
	private IngredientResolver ingredientResolver;

	@Autowired
	private RecipeMatcher recipeMatcher;

	@Autowired
	private SecurityUtil securityUtil;

	@Override
	@Transactional
	public Long createRecipeDraft(String title) {
		if (title == null || title.isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食谱标题不能为空");
		}
		Recipe recipe = new Recipe();
		recipe.setTitle(title);
		recipe.setStatus(RecipeStatus.DRAFT);
		recipe.setCreateTime(new Date());
		recipe.setStepCount(0);
		recipe.setCreatorUserId(requireCurrentUser().getUserId());
		recipeRepository.save(recipe);
		return recipe.getRecipeId();
	}

	@Override
	@Transactional
	public Void modifyRecipeTitle(Long recipeId, String title) {
		if (title == null || title.isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食谱标题不能为空");
		}
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		recipe.setTitle(title);
		recipeRepository.save(recipe);
		return null;
	}

	@Override
	@Transactional
	public Void modifyRecipeDescription(Long recipeId, String description) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		recipe.setDescription(description);
		recipeRepository.save(recipe);
		return null;
	}

	@Override
	@Transactional
	public Void publishRecipeDraft(Long recipeId) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (recipe.getStatus() == RecipeStatus.PUBLISHED) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "已经发布了这篇食谱");
		}
		recipe.setStatus(RecipeStatus.PUBLISHED);
		recipeRepository.save(recipe);
		return null;
	}

	@Override
	@Transactional
	public Void deleteRecipe(Long recipeId) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe) && requireCurrentUser().getRole() != Role.ADMIN) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		recipeRepository.delete(recipe);
		return null;
	}

	@Override
	@Transactional
	public Void hideRecipe(Long recipeId) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		recipe.setStatus(RecipeStatus.HIDDEN);
		recipeRepository.save(recipe);
		return null;
	}

	@Override
	@Transactional
	public RecipeVO addRecipeStep(Long recipeId, Integer index, RecipeStepVO stepVO) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		RecipeStep newStep = buildStepForCreate(stepVO);
		List<RecipeStep> orderedSteps = getOrderedSteps(recipe);
		int insertIndex = resolveInsertIndex(index, stepVO != null ? stepVO.getStepNumber() : null,
				orderedSteps.size()); // NOTE: index 优先决定插入位置
		orderedSteps.add(insertIndex, newStep);
		reindexSteps(orderedSteps);
		recipe.setSteps(orderedSteps);
		recipe.setStepCount(orderedSteps.size());
		return recipeRepository.save(recipe).toVO();
	}

	@Override
	@Transactional
	public RecipeVO modifyRecipeStep(Long recipeId, Long stepId, RecipeStepVO stepVO) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (stepId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "步骤ID不能为空");
		}
		List<RecipeStep> orderedSteps = getOrderedSteps(recipe);
		RecipeStep targetStep = orderedSteps.stream()
				.filter(step -> Objects.equals(step.getId(), stepId))
				.findFirst()
				.orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "步骤不存在"));
		if (stepVO != null) {
			if (stepVO.getDescription() != null) {
				targetStep.setDescription(stepVO.getDescription());
			}
			if (stepVO.getImageUrls() != null) {
				targetStep.setImageUrls(new ArrayList<>(stepVO.getImageUrls()));
			}
			if (stepVO.getStepNumber() != null) {
				orderedSteps.remove(targetStep);
				int insertIndex = calculateInsertIndex(stepVO.getStepNumber(), orderedSteps.size());
				orderedSteps.add(insertIndex, targetStep);
			}
		}
		reindexSteps(orderedSteps);
		recipe.setSteps(orderedSteps);
		return recipeRepository.save(recipe).toVO();
	}

	@Override
	@Transactional
	public RecipeVO deleteRecipeStep(Long recipeId, Long stepId) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (stepId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "步骤ID不能为空");
		}
		List<RecipeStep> orderedSteps = getOrderedSteps(recipe);
		boolean removed = orderedSteps.removeIf(step -> Objects.equals(step.getId(), stepId));
		if (!removed) {
			throw new BusinessException(ErrorCode.NOT_FOUND, "步骤不存在");
		}
		reindexSteps(orderedSteps);
		recipe.setSteps(orderedSteps);
		recipe.setStepCount(orderedSteps.size());
		return recipeRepository.save(recipe).toVO();
	}

	@Override
	@Transactional
	public RecipeVO swapRecipeSteps(Long recipeId, Integer firstIndex, Integer secondIndex) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (firstIndex == null || secondIndex == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "索引不能为空");
		}
		if (firstIndex.equals(secondIndex)) {
			return recipe.toVO();
		}
		List<RecipeStep> orderedSteps = getOrderedSteps(recipe);
		int normalizedFirst = validateIndex(firstIndex, orderedSteps.size());
		int normalizedSecond = validateIndex(secondIndex, orderedSteps.size());
		RecipeStep temp = orderedSteps.get(normalizedFirst);
		orderedSteps.set(normalizedFirst, orderedSteps.get(normalizedSecond));
		orderedSteps.set(normalizedSecond, temp);
		reindexSteps(orderedSteps);
		recipe.setSteps(orderedSteps);
		return recipeRepository.save(recipe).toVO();
	}

	@Override
	@Transactional
	public RecipeIngredientVO modifyRecipeIngredient(Long recipeId, String description) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (description == null || description.isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食材描述不能为空");
		}
		IngredientEnum ingredientEnum = ingredientResolver.resolve(description);
		RecipeIngredient recipeIngredient = recipeIngredientRepository.findByRecipe_RecipeId(recipeId)
				.orElse(new RecipeIngredient());
		recipeIngredient.setRecipe(recipe);
		recipeIngredient.setIngredient(ingredientEnum);
		recipeIngredient.setDescription(description);
		recipeIngredientRepository.save(recipeIngredient);
		return recipeIngredient.toVO();
	}

	@Override
	@Transactional
	public RecipeIngredientVO setRecipeIngredientTag(Long recipeId, IngredientEnum ingredient) {
		Recipe recipe = findRecipeById(recipeId);
		if (!judgeRecipeCreator(recipe)) {
			throw new BusinessException(ErrorCode.FORBIDDEN, "不能操作其他人的食谱");
		}
		if (ingredient == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食材类型不能为空");
		}
		RecipeIngredient recipeIngredient = recipeIngredientRepository.findByRecipe_RecipeId(recipeId)
				.orElse(new RecipeIngredient());
		recipeIngredient.setRecipe(recipe);
		recipeIngredient.setIngredient(ingredient);
		recipeIngredientRepository.save(recipeIngredient);
		return recipeIngredient.toVO();
	}

	@Override
	public org.springframework.data.domain.Page<RecipeVO> searchRecipes(String keyword, Date startDate,
			com.java.NaniYiMiDa.enumx.IngredientEnum tag, org.springframework.data.domain.Pageable pageable) {
		boolean isKeywordPresent = keyword != null && !keyword.isBlank();
		boolean isTagPresent = tag != null;

		if (!isKeywordPresent && !isTagPresent) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "keyword 或 tag 必须至少提供其一");
		}

		Page<Recipe> page;
		if (isTagPresent && isKeywordPresent) {
			page = recipeRepository.searchByStatusAndStartDateAndKeywordAndIngredient(RecipeStatus.PUBLISHED, startDate,
					keyword.trim(), tag, pageable);
		} else if (isTagPresent) {
			page = recipeRepository.searchByStatusAndStartDateAndIngredient(RecipeStatus.PUBLISHED, startDate, tag,
					pageable);
		} else {
			page = recipeRepository.searchByStatusAndStartDateAndKeyword(RecipeStatus.PUBLISHED, startDate,
					keyword.trim(), pageable);
		}

		return page.map(Recipe::toVO);
	}

	@Override
	public org.springframework.data.domain.Page<RecipeVO> getRecentRecipes(Date startDate,
			org.springframework.data.domain.Pageable pageable) {
		Page<Recipe> recipePage;
		if (startDate == null) {
			recipePage = recipeRepository.findByStatus(RecipeStatus.PUBLISHED, pageable);
		} else {
			recipePage = recipeRepository.findByStatusAndCreateTimeAfter(RecipeStatus.PUBLISHED, startDate, pageable);
		}

		return recipePage.map(Recipe::toVO);
	}

	@Override
	public org.springframework.data.domain.Page<RecipeVO> getUserRecipesById(Long userId, Date startDate,
			org.springframework.data.domain.Pageable pageable) {
		if (userId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "用户ID不能为空");
		}

		Long currentUserId = requireCurrentUser().getUserId();

		Page<Recipe> recipePage;
		boolean isCurrentUser = currentUserId.equals(userId);

		if (isCurrentUser) {
			if (startDate == null) {
				recipePage = recipeRepository.findByCreatorUserIdAndStatusNot(
						userId, RecipeStatus.DRAFT, pageable);
			} else {
				recipePage = recipeRepository.findByCreatorUserIdAndStatusNotAndCreateTimeAfter(
						userId, RecipeStatus.DRAFT, startDate, pageable);
			}
		} else {
			if (startDate == null) {
				recipePage = recipeRepository.findByCreatorUserIdAndStatus(
						userId, RecipeStatus.PUBLISHED, pageable);
			} else {
				recipePage = recipeRepository.findByCreatorUserIdAndStatusAndCreateTimeAfter(
						userId, RecipeStatus.PUBLISHED, startDate, pageable);
			}
		}

		return recipePage.map(Recipe::toVO);
	}

	@Override
	public List<RecipeVO> getCurrentUserDraft() {
		Long userId = requireCurrentUser().getUserId();

		List<Recipe> userRecipes = recipeRepository.findByCreatorUserId(userId);

		List<RecipeVO> draftRecipes = new ArrayList<>();

		for (Recipe recipe : userRecipes) {
			if (recipe.getStatus() == RecipeStatus.DRAFT) {
				draftRecipes.add(recipe.toVO());
			}
		}

		return draftRecipes;
	}

	@Override
	public RecipeVO getRecipeById(Long recipeId) {
		Recipe recipe = findRecipeById(recipeId);
		// 只有已发布的食谱或者作者本人可以查看
		if (recipe.getStatus() != RecipeStatus.PUBLISHED) {
			User currentUser = securityUtil.getCurrentUser();
			if (currentUser == null || !recipe.getCreatorUserId().equals(currentUser.getUserId())) {
				throw new BusinessException(ErrorCode.FORBIDDEN, "无权查看该食谱");
			}
		}
		return recipe.toVO();
	}

	private RecipeStep buildStepForCreate(RecipeStepVO stepVO) {
		if (stepVO == null || stepVO.getDescription() == null || stepVO.getDescription().isBlank()) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "步骤内容不能为空");
		}
		RecipeStep step = new RecipeStep();
		step.setDescription(stepVO.getDescription());
		if (stepVO.getImageUrls() != null) {
			step.setImageUrls(new ArrayList<>(stepVO.getImageUrls()));
		}
		return step;
	}

	private List<RecipeStep> getOrderedSteps(Recipe recipe) {
		List<RecipeStep> raw = recipe.getSteps();
		List<RecipeStep> steps = raw == null ? new ArrayList<>() : new ArrayList<>(raw);
		steps.sort(Comparator
				.comparing((RecipeStep s) -> s.getStepNumber() == null ? Integer.MAX_VALUE : s.getStepNumber())
				.thenComparing(s -> s.getId() == null ? Long.MAX_VALUE : s.getId()));
		return steps;
	}

	private int calculateInsertIndex(Integer desiredStepNumber, int currentSize) {
		if (desiredStepNumber == null) {
			return currentSize;
		}
		int index = desiredStepNumber - 1;
		if (index < 0) {
			index = 0;
		}
		if (index > currentSize) {
			index = currentSize;
		}
		return index;
	}

	private int resolveInsertIndex(Integer index, Integer fallbackStepNumber, int currentSize) {
		if (index != null) {
			if (index < 0) {
				return 0;
			}
			if (index > currentSize) {
				return currentSize;
			}
			return index;
		}
		return calculateInsertIndex(fallbackStepNumber, currentSize);
	}

	private int validateIndex(Integer index, int size) {
		if (index < 0 || index >= size) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "索引超出范围");
		}
		return index;
	}

	private void reindexSteps(List<RecipeStep> steps) {
		int order = 1;
		for (RecipeStep step : steps) {
			step.setStepNumber(order++);
		}
	}

	private Recipe findRecipeById(Long recipeId) {
		if (recipeId == null) {
			throw new BusinessException(ErrorCode.BAD_REQUEST, "食谱ID不能为空");
		}
		return recipeRepository.findById(recipeId)
				.orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "食谱不存在"));
	}

	@NonNull
	private User requireCurrentUser() {
		User user = securityUtil.getCurrentUser();
		if (user == null) {
			throw new BusinessException(ErrorCode.UNAUTHORIZED, "未登录");
		}
		return user;
	}

	private Boolean judgeRecipeCreator(Recipe recipe) {
		return Objects.equals(recipe.getCreatorUserId(), requireCurrentUser().getUserId());
	}
}
