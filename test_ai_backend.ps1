# 🧪 AI BACKEND TEST SCRIPT

# This PowerShell script tests your AI backend before APK testing
# Run this to ensure backend is working correctly

Write-Host "`n════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🧪 AI BACKEND HEALTH CHECK" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Step 1: Check if backend is running
Write-Host "1️⃣  Checking if backend is running on port 5000..." -ForegroundColor Yellow
$backendRunning = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
if ($backendRunning) {
    Write-Host "   ✅ Backend is running" -ForegroundColor Green
} else {
    Write-Host "   ❌ Backend NOT running!" -ForegroundColor Red
    Write-Host "   Start backend: cd backend && node server.js`n" -ForegroundColor Yellow
    exit 1
}

# Step 2: Test health endpoint
Write-Host "`n2️⃣  Testing /health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5
    Write-Host "   ✅ Health check passed" -ForegroundColor Green
    Write-Host "   Status: $($health.status)" -ForegroundColor White
    Write-Host "   Message: $($health.message)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Test AI health endpoint
Write-Host "`n3️⃣  Testing /api/ai/health endpoint..." -ForegroundColor Yellow
try {
    $aiHealth = Invoke-RestMethod -Uri "http://localhost:5000/api/ai/health" -Method GET -TimeoutSec 5
    Write-Host "   ✅ AI health check passed" -ForegroundColor Green
    Write-Host "   Status: $($aiHealth.status)" -ForegroundColor White
    Write-Host "   AI Engine: $($aiHealth.aiEngine)" -ForegroundColor White
    Write-Host "   Gemini Key: $($aiHealth.geminiKey)" -ForegroundColor White
    Write-Host "   OpenAI Key: $($aiHealth.openaiKey)" -ForegroundColor White
    
    if ($aiHealth.status -ne "Configured") {
        Write-Host "`n   ⚠️  WARNING: AI not configured!" -ForegroundColor Red
        Write-Host "   Add GEMINI_API_KEY or OPENAI_API_KEY to backend/.env" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ AI health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 4: Test actual AI chat (this will take 3-10 seconds)
Write-Host "`n4️⃣  Testing AI chat endpoint (this may take 5-10 seconds)..." -ForegroundColor Yellow
$testStart = Get-Date
try {
    $body = @{
        message = "Hello"
        language = "en"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:5000/api/ai/chat" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30
    $testEnd = Get-Date
    $duration = ($testEnd - $testStart).TotalSeconds
    
    Write-Host "   ✅ AI chat test passed!" -ForegroundColor Green
    Write-Host "   Response time: $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    Write-Host "   Message preview: $($response.message.Substring(0, [Math]::Min(100, $response.message.Length)))..." -ForegroundColor Gray
    
    if ($duration -gt 15) {
        Write-Host "`n   ⚠️  WARNING: Response took longer than 15 seconds!" -ForegroundColor Yellow
        Write-Host "   This may cause timeouts in APK. Check AI API key and network." -ForegroundColor Yellow
    } elseif ($duration -lt 10) {
        Write-Host "`n   🎉 Excellent! Fast response time." -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ AI chat test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n   Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Check backend terminal for error logs" -ForegroundColor White
    Write-Host "   - Verify GEMINI_API_KEY or OPENAI_API_KEY in .env" -ForegroundColor White
    Write-Host "   - Test API key: curl `"https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_KEY`"" -ForegroundColor White
    exit 1
}

# Summary
Write-Host "`n════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ✅ ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Start ngrok: ngrok http 5000" -ForegroundColor White
Write-Host "   2. Copy ngrok HTTPS URL" -ForegroundColor White
Write-Host "   3. Update lib/config/api_config.dart:" -ForegroundColor White
Write-Host "      - ngrokUrl = 'https://YOUR_URL.ngrok.io'" -ForegroundColor Gray
Write-Host "      - useNgrok = true" -ForegroundColor Gray
Write-Host "   4. Rebuild APK: flutter build apk" -ForegroundColor White
Write-Host "   5. Install on device and test" -ForegroundColor White

Write-Host "`n💡 Tip: Run this script again after starting ngrok to test via ngrok URL" -ForegroundColor Magenta
Write-Host "`n"
