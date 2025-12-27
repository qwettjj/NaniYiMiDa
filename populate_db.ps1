$baseUrl = "http://localhost:8080/api"
$phone = "16612341234"
$password = "test1234"
$nickname = "ChefMaster"

# 1. Register
Write-Host "Registering..."
$registerUrl = "$baseUrl/users/register"
$registerBody = '{"phone":"' + $phone + '","password":"' + $password + '","nickName":"' + $nickname + '"}'
try {
    Invoke-RestMethod -Uri $registerUrl -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($registerBody)) -ContentType "application/json; charset=utf-8"
} catch {
    Write-Host "User might already exist, proceeding to login..."
}

# 2. Login
Write-Host "Logging in..."
$loginUrl = "$baseUrl/users/login?phone=$phone&password=$password"
$loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post
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
    $draftBody = '{"title":"' + $r.title + '"}'
    try {
        $draftRes = Invoke-RestMethod -Uri "$baseUrl/recipes/draft" -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($draftBody)) -ContentType "application/json; charset=utf-8"
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
