package com.java.NaniYiMiDa.po;

import com.java.NaniYiMiDa.vo.FavoriteVO;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Favorite {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long favouriteId;

	@Column(name = "recipe_id", nullable = false)
	private Long recipeId;

	@Column(name = "user_id", nullable = false)
	private Long userId;

	public FavoriteVO toVO() {
		FavoriteVO vo = new FavoriteVO();
		vo.setFavouriteId(favouriteId);
		vo.setRecipeId(recipeId);
		vo.setUserId(userId);
		return vo;
	}
}

