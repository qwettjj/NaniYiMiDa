$baseUrl = "http://localhost:8080/api"
$phone = "16612341234"
$password = "test1234"
$nickname = "ChefMaster"

# 1. Register
Write-Host "Registering..."
$registerUrl = "$baseUrl/users/register"
$registerBody = '{"phoneNumber":"' + $phone + '","password":"' + $password + '","nickName":"' + $nickname + '"}'
try {
    $regRes = Invoke-RestMethod -Uri $registerUrl -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($registerBody)) -ContentType "application/json; charset=utf-8"
    Write-Host "Register Response: $($regRes | ConvertTo-Json -Depth 2)"
} catch {
    Write-Host "Register request failed: $_"
}

# 2. Login
Write-Host "Logging in..."
$loginUrl = "$baseUrl/users/login?phone=$phone&password=$password"
$loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post
Write-Host "Login Response: $($loginResponse | ConvertTo-Json -Depth 2)"
$token = $loginResponse.data
Write-Host "Token: $token"

if (-not $token) {
    Write-Error "Login failed."
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json; charset=utf-8"
}

# 3. Create Recipes
$recipes = @(
    @{
        title = "Braised Pork"
        description = "Delicious"
        ingredients = "Pork, Sugar"
        steps = @("Cut", "Cook")
    }
)

foreach ($r in $recipes) {
    # Create Draft
    try {
        $draftRes = Invoke-RestMethod -Uri "$baseUrl/recipes/create?title=$($r.title)" -Method Post -Headers $headers
        $recipeId = $draftRes.data
        Write-Host "Created draft: $recipeId for $($r.title)"
    } catch {
        Write-Error "Failed to create draft: $_"
        continue
    }

    if (-not $recipeId) {
        continue
    }

    # Publish
    Invoke-RestMethod -Uri "$baseUrl/recipes/$recipeId/publish" -Method Post -Headers $headers
    Write-Host "Published recipe: $($r.title)"
}
