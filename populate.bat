@echo off
set TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIyIiwiZXhwIjoxNzY2OTA1NzU0fQ.g67q2aqgHwPTW8TXOn0_gM_eykcfYIF2NCX92gp3ugw

echo Creating draft...
curl -X POST http://localhost:8080/api/recipes/draft -H "Content-Type: application/json" -H "Authorization: Bearer %TOKEN%" -d "{\"title\":\"TestRecipe\"}"
