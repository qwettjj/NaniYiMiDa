package com.java.NaniYiMiDa;

import com.java.NaniYiMiDa.vo.ResultVO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;

import java.util.HashMap;
import java.util.Map;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
public class PopulateDataTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void populate() {
        String baseUrl = "http://localhost:8080/api";

        // 1. Register (ignore failure)
        Map<String, String> regMap = new HashMap<>();
        regMap.put("phone", "16612341234");
        regMap.put("password", "test1234");
        regMap.put("nickName", "ChefMaster");
        try {
            restTemplate.postForEntity(baseUrl + "/users/register", regMap, ResultVO.class);
        } catch (Exception e) {
        }

        // 2. Login
        String loginUrl = baseUrl + "/users/login?phone=16612341234&password=test1234";
        ResponseEntity<ResultVO> loginRes = restTemplate.postForEntity(loginUrl, null, ResultVO.class);
        String token = (String) loginRes.getBody().getData();
        System.out.println("Token: " + token);

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        createRecipe(baseUrl, headers, "红烧肉", "肥而不腻", "五花肉, 冰糖", new String[] { "切肉", "炖煮" });
        createRecipe(baseUrl, headers, "西红柿炒鸡蛋", "经典家常", "西红柿, 鸡蛋", new String[] { "炒蛋", "炒西红柿" });
    }

    private void createRecipe(String baseUrl, HttpHeaders headers, String title, String desc, String ingredients,
            String[] steps) {
        // Draft
        // Use query param for title as per Controller
        HttpEntity<Void> request = new HttpEntity<>(null, headers);
        ResponseEntity<ResultVO> draftRes = restTemplate.postForEntity(baseUrl + "/recipes/create?title=" + title,
                request,
                ResultVO.class);

        System.out.println("Draft Response: " + draftRes.getBody());

        if (draftRes.getBody().getData() == null) {
            System.err.println("Failed to create draft: " + draftRes.getBody().getMessage());
            return;
        }

        // ResultVO data is Integer/Long, but Jackson might map it to Integer
        Object data = draftRes.getBody().getData();
        Long recipeId = Long.valueOf(data.toString());
        System.out.println("Created recipe: " + recipeId);

        // Description
        restTemplate.exchange(baseUrl + "/recipes/" + recipeId + "/description?description=" + desc, HttpMethod.PUT,
                new HttpEntity<>(null, headers), ResultVO.class);

        // Ingredients
        HttpEntity<String> ingReq = new HttpEntity<>(ingredients, headers);
        restTemplate.exchange(baseUrl + "/recipes/" + recipeId + "/ingredient/description", HttpMethod.PUT, ingReq,
                ResultVO.class);

        // Steps
        for (String step : steps) {
            Map<String, String> stepMap = new HashMap<>();
            stepMap.put("description", step);
            stepMap.put("image", "");
            restTemplate.postForEntity(baseUrl + "/recipes/" + recipeId + "/steps", new HttpEntity<>(stepMap, headers),
                    ResultVO.class);
        }

        // Publish
        restTemplate.postForEntity(baseUrl + "/recipes/" + recipeId + "/publish", new HttpEntity<>(null, headers),
                ResultVO.class);
        System.out.println("Published: " + title);
    }
}
