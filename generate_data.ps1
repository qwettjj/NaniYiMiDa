
$baseUrl = "http://10.52.19.170:8080/api"
$phone = "16612341234"
$password = "test1234"

# 1. Login
Write-Host "Logging in..."
$loginUrl = "$baseUrl/users/login?phone=$phone&password=$password"
try {
    $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post
    if ($loginResponse.code -eq "000") {
        $token = $loginResponse.data
        Write-Host "Login successful. Token: $token"
    }
    else {
        Write-Error "Login failed: $($loginResponse.message)"
        exit
    }
}
catch {
    Write-Error "Login request failed: $_"
    exit
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# Fake Data
$recipes = @(
    @{
        title       = "红烧肉"
        description = "肥而不腻，入口即化，是一道经典的家常菜。"
        steps       = @(
            @{ description = "五花肉切块，冷水下锅焯水。" },
            @{ description = "锅中放油，炒糖色。" },
            @{ description = "放入肉块翻炒上色，加入葱姜蒜八角。" },
            @{ description = "加入生抽、老抽、料酒，加热水没过肉。" },
            @{ description = "小火炖煮40分钟，大火收汁即可。" }
        )
        ingredients = "五花肉, 冰糖, 葱, 姜, 蒜, 八角, 生抽, 老抽, 料酒"
    },
    @{
        title       = "西红柿炒鸡蛋"
        description = "酸甜可口，营养丰富，做法简单。"
        steps       = @(
            @{ description = "鸡蛋打散，西红柿切块。" },
            @{ description = "锅中放油，将鸡蛋炒熟盛出。" },
            @{ description = "锅中留底油，炒西红柿出汁。" },
            @{ description = "加入鸡蛋，加盐和糖调味。" },
            @{ description = "翻炒均匀撒上葱花出锅。" }
        )
        ingredients = "西红柿, 鸡蛋, 葱, 盐, 糖"
    },
    @{
        title       = "宫保鸡丁"
        description = "酸甜微辣，鸡肉滑嫩，花生香脆。"
        steps       = @(
            @{ description = "鸡胸肉切丁，加淀粉料酒腌制。" },
            @{ description = "花生米炸脆备用。" },
            @{ description = "调好宫保汁（糖醋生抽淀粉水）。" },
            @{ description = "炒香干辣椒花椒，下鸡丁滑熟。" },
            @{ description = "加入葱姜蒜和配菜，倒入料汁和花生米快速翻炒。" }
        )
        ingredients = "鸡胸肉, 花生米, 干辣椒, 花椒, 葱, 姜, 蒜"
    },
    @{
        title       = "清蒸鲈鱼"
        description = "鲜嫩多汁，原汁原味。"
        steps       = @(
            @{ description = "鲈鱼处理干净，改刀。" },
            @{ description = "盘底铺葱姜，鱼身抹料酒。" },
            @{ description = "水开上锅蒸8分钟，关火焖2分钟。" },
            @{ description = "倒掉蒸鱼水，铺上葱丝红椒丝。" },
            @{ description = "淋上蒸鱼豉油，浇上热油激发出香味。" }
        )
        ingredients = "鲈鱼, 葱, 姜, 红椒, 蒸鱼豉油, 油"
    },
    @{
        title       = "麻婆豆腐"
        description = "麻辣鲜香，下饭神器。"
        steps       = @(
            @{ description = "豆腐切块焯水去除豆腥味。" },
            @{ description = "牛肉剁碎炒酥。" },
            @{ description = "炒香豆瓣酱和豆豉，加入辣椒面。" },
            @{ description = "加水煮开，放入豆腐和牛肉末。" },
            @{ description = "勾芡三次，撒上花椒粉和葱花。" }
        )
        ingredients = "豆腐, 牛肉末, 豆瓣酱, 豆豉, 花椒粉, 葱"
    }
)

foreach ($recipe in $recipes) {
    Write-Host "Creating recipe: $($recipe.title)..."
    
    # 1. Create Draft
    $createUrl = "$baseUrl/recipes/create?title=$([uri]::EscapeDataString($recipe.title))"
    try {
        $createRes = Invoke-RestMethod -Uri $createUrl -Method Post -Headers $headers
        $recipeId = $createRes.data
        Write-Host "  Created draft ID: $recipeId"
    }
    catch {
        Write-Error "  Failed to create draft: $_"
        continue
    }

    # 2. Update Description
    $descUrl = "$baseUrl/recipes/$recipeId/description?description=$([uri]::EscapeDataString($recipe.description))"
    try {
        Invoke-RestMethod -Uri $descUrl -Method Put -Headers $headers | Out-Null
        Write-Host "  Updated description"
    }
    catch {
        Write-Error "  Failed to update description: $_"
    }

    # 3. Add Steps
    $stepIndex = 1
    foreach ($step in $recipe.steps) {
        $stepUrl = "$baseUrl/recipes/$recipeId/steps"
        $stepBody = @{
            stepNumber  = $stepIndex
            description = $step.description
            imageUrls   = @()
        } | ConvertTo-Json
        try {
            Invoke-RestMethod -Uri $stepUrl -Method Post -Headers $headers -Body $stepBody | Out-Null
            Write-Host "  Added step $stepIndex"
        }
        catch {
            Write-Error "  Failed to add step ${stepIndex}: $_"
        }
        $stepIndex++
    }

    # 4. Update Ingredients (Description)
    $ingUrl = "$baseUrl/recipes/$recipeId/ingredient/description"
    try {
        Invoke-RestMethod -Uri $ingUrl -Method Put -Headers $headers -Body ($recipe.ingredients | ConvertTo-Json) | Out-Null
        Write-Host "  Updated ingredients"
    }
    catch {
        Write-Error "  Failed to update ingredients: $_"
    }

    # 5. Publish
    $pubUrl = "$baseUrl/recipes/$recipeId/publish"
    try {
        Invoke-RestMethod -Uri $pubUrl -Method Post -Headers $headers | Out-Null
        Write-Host "  Published recipe"
    }
    catch {
        Write-Error "  Failed to publish: $_"
    }
    
    Write-Host "----------------------------------------"
}

Write-Host "Done!"
