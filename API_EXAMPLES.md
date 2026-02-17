# API Testing Examples

Collection of example requests for testing the Know Your Rights API.

## Health Check

```bash
curl http://localhost:3000/health
```

## Classification Examples

### Example 1: Salary Issue

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "My employer has not paid my salary for the last 3 months despite multiple requests"
  }'
```

Expected response:
```json
{
  "issue_id": "salary_not_paid",
  "confidence": 0.92,
  "fallback": false
}
```

### Example 2: Landlord Dispute

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "My landlord refuses to return my security deposit even after I moved out 2 months ago"
  }'
```

Expected response:
```json
{
  "issue_id": "landlord_dispute",
  "confidence": 0.88,
  "fallback": false
}
```

### Example 3: Online Fraud

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "I ordered a phone online but received a fake product and the seller is not responding"
  }'
```

Expected response:
```json
{
  "issue_id": "online_fraud",
  "confidence": 0.85,
  "fallback": false
}
```

### Example 4: Consumer Complaint

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The washing machine I bought stopped working after 1 month and the company refuses warranty service"
  }'
```

Expected response:
```json
{
  "issue_id": "consumer_complaint",
  "confidence": 0.91,
  "fallback": false
}
```

### Example 5: Police Issue

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Police detained me without any warrant and are demanding money for release"
  }'
```

Expected response:
```json
{
  "issue_id": "police_issue",
  "confidence": 0.87,
  "fallback": false
}
```

### Example 6: Low Confidence (Unknown)

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello how are you"
  }'
```

Expected response:
```json
{
  "issue_id": "unknown",
  "confidence": 0.15,
  "fallback": true
}
```

### Example 7: Multi-language (Hindi)

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "मेरा वेतन पिछले 2 महीने से नहीं मिला है",
    "lang": "hi"
  }'
```

Expected response:
```json
{
  "issue_id": "salary_not_paid",
  "confidence": 0.89,
  "fallback": false
}
```

## Error Cases

### Example 8: Text Too Short

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "hi"
  }'
```

Expected response (400):
```json
{
  "error": "Text must be at least 3 characters"
}
```

### Example 9: Text Too Long

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{
    "text": "'$(python3 -c 'print("a" * 501)')'"
  }'
```

Expected response (400):
```json
{
  "error": "Text must not exceed 500 characters"
}
```

### Example 10: Missing Text Field

```bash
curl -X POST http://localhost:3000/api/classify \
  -H "Content-Type: application/json" \
  -d '{}'
```

Expected response (400):
```json
{
  "error": "Text field is required"
}
```

## Using Postman

1. Create a new POST request
2. URL: `http://localhost:3000/api/classify`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "text": "Your problem description here",
  "lang": "en"
}
```

## Using JavaScript/Node.js

```javascript
const axios = require('axios');

async function classifyProblem(text, lang = 'en') {
  try {
    const response = await axios.post('http://localhost:3000/api/classify', {
      text,
      lang
    });
    
    console.log('Classification Result:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Test it
classifyProblem('My landlord is not returning my deposit');
```

## Using Python

```python
import requests

def classify_problem(text, lang='en'):
    url = 'http://localhost:3000/api/classify'
    payload = {'text': text, 'lang': lang}
    
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f'Error: {e}')
        return None

# Test it
result = classify_problem('I was scammed by an online seller')
print(result)
```

## Rate Limiting Test

To test rate limiting, send many requests quickly:

```bash
for i in {1..150}; do
  curl -X POST http://localhost:3000/api/classify \
    -H "Content-Type: application/json" \
    -d '{"text": "Test request number '$i'"}' &
done
wait
```

After 100 requests within 15 minutes, you should see:
```json
{
  "error": "Too many requests, please try again later"
}
```
