package com.java.NaniYiMiDa.service.ingredient.impl;

import com.java.NaniYiMiDa.enumx.IngredientEnum;
import com.java.NaniYiMiDa.service.ingredient.IngredientResolver;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.Set;

@Component
@Primary
public class ImprovedIngredientResolver implements IngredientResolver {

    private final Map<String, IngredientEnum> lookupMap;

    private final List<String> sortedLookupKeys;

    public ImprovedIngredientResolver() {
        lookupMap = new HashMap<>();

        for (IngredientEnum ingredient : IngredientEnum.values()) {
            Set<String> matchableStrings = ingredient.getMatchableStrings();
            for (String matchable : matchableStrings) {
                lookupMap.put(matchable, ingredient);
            }
        }

        sortedLookupKeys = new ArrayList<>(lookupMap.keySet());
        sortedLookupKeys.sort(Comparator.comparingInt(String::length).reversed());

        System.out.println("ImprovedIngredientResolver initialized with " + lookupMap.size() + " matchable keys.");
    }

    @Override
    public IngredientEnum resolve(String description) {
        if (description == null || description.isBlank()) {
            return null;
        }

        String searchTarget = description.toUpperCase().replaceAll("\\s+", " ").trim();

        if (lookupMap.containsKey(searchTarget)) {
            return lookupMap.get(searchTarget);
        }

        for (String key : sortedLookupKeys) {
            Pattern pattern = Pattern.compile("\\b" + Pattern.quote(key) + "\\b");
            Matcher matcher = pattern.matcher(searchTarget);

            if (matcher.find()) {
                return lookupMap.get(key);
            }
        }

        for (String key : sortedLookupKeys) {
            if (searchTarget.contains(key)) {
                return lookupMap.get(key);
            }
        }

        return null;
    }
}

