# Client Integration Guide

## 🌐 Production API URL

```
https://know-your-right-backend.onrender.com
```

---

## 📡 API Endpoint

### Classify Legal Issue

**POST** `/api/classify`

Classifies a user's legal problem into one of the predefined categories.

#### Request Format

```http
POST https://know-your-right-backend.onrender.com/api/classify
Content-Type: application/json

{
  "text": "My employer has not paid my salary for 3 months"
}
```

#### Response Format

**Success Response (200 OK):**
```json
{
  "issue_id": "salary_not_paid",
  "confidence": 0.95,
  "fallback": false
}
```

**Low Confidence Response (200 OK):**
```json
{
  "issue_id": "unknown",
  "confidence": 0.45,
  "fallback": true
}
```

**Error Response (400 Bad Request):**
```json
{
  "error": "Text must be at least 15 characters"
}
```

**Rate Limit Response (429 Too Many Requests):**
```json
{
  "error": "Too many requests, please try again later."
}
```

---

## 🏷️ Issue Categories

| Issue ID | Description |
|----------|-------------|
| `salary_not_paid` | Unpaid wages, salary disputes |
| `landlord_dispute` | Rental issues, eviction, property problems |
| `online_fraud` | E-commerce scams, online fraud |
| `consumer_complaint` | Product/service complaints |
| `police_issue` | Police harassment, unlawful detention |
| `unknown` | Cannot determine category (low confidence) |

---

## ⚠️ Important Constraints

- **Minimum Text Length**: 15 characters
- **Maximum Text Length**: 500 characters
- **Rate Limit**: 20 requests per minute per IP
- **Response Time**: ~2-5 seconds (AI processing)
- **Confidence Threshold**: 0.6 (below this returns "unknown")

---

## 🚀 Integration Examples

### React Native (JavaScript)

```javascript
const classifyIssue = async (userText) => {
  try {
    const response = await fetch('https://know-your-right-backend.onrender.com/api/classify', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ text: userText }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Classification failed');
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('API Error:', error.message);
    throw error;
  }
};

// Usage
const result = await classifyIssue("My landlord refuses to return my security deposit");
console.log(`Issue: ${result.issue_id}, Confidence: ${result.confidence}`);
```

### React Native with Error Handling

```javascript
import { useState } from 'react';

const useIssueClassifier = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const classifyIssue = async (text) => {
    setLoading(true);
    setError(null);

    try {
      // Validate input length
      if (text.length < 15) {
        throw new Error('Please provide more details (at least 15 characters)');
      }
      if (text.length > 500) {
        throw new Error('Description is too long (maximum 500 characters)');
      }

      const response = await fetch('https://know-your-right-backend.onrender.com/api/classify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text }),
        timeout: 10000, // 10 second timeout
      });

      if (response.status === 429) {
        throw new Error('Too many requests. Please wait a moment and try again.');
      }

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to classify issue');
      }

      const data = await response.json();
      
      // Handle fallback case
      if (data.fallback) {
        console.warn('Low confidence classification:', data);
      }

      return data;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  return { classifyIssue, loading, error };
};

// In your component
const { classifyIssue, loading, error } = useIssueClassifier();

const handleSubmit = async () => {
  try {
    const result = await classifyIssue(userInput);
    
    if (result.fallback) {
      // Show message to user about uncertain classification
      showWarning('We are not quite sure about your issue category');
    }
    
    // Navigate to appropriate screen based on issue_id
    navigateToIssueScreen(result.issue_id);
  } catch (err) {
    showError(err.message);
  }
};
```

### Flutter (Dart)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class IssueClassifier {
  static const String baseUrl = 'https://know-your-right-backend.onrender.com';

  Future<Map<String, dynamic>> classifyIssue(String text) async {
    // Validate input
    if (text.length < 15) {
      throw Exception('Text must be at least 15 characters');
    }
    if (text.length > 500) {
      throw Exception('Text must be less than 500 characters');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/classify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      }

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Classification failed');
      }

      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}

// Usage
final classifier = IssueClassifier();
try {
  final result = await classifier.classifyIssue(
    "I was scammed by an online seller"
  );
  
  print('Issue ID: ${result['issue_id']}');
  print('Confidence: ${result['confidence']}');
  
  if (result['fallback'] == true) {
    // Handle uncertain classification
    showSnackbar('We could not determine your exact issue');
  }
} catch (e) {
  print('Error: $e');
}
```

### Swift (iOS)

```swift
import Foundation

struct ClassificationRequest: Codable {
    let text: String
}

struct ClassificationResponse: Codable {
    let issue_id: String
    let confidence: Double
    let fallback: Bool
}

struct ErrorResponse: Codable {
    let error: String
}

class IssueClassifier {
    static let baseURL = "https://know-your-right-backend.onrender.com"
    
    func classifyIssue(text: String, completion: @escaping (Result<ClassificationResponse, Error>) -> Void) {
        // Validate input
        guard text.count >= 15 else {
            completion(.failure(NSError(domain: "", code: 400, 
                userInfo: [NSLocalizedDescriptionKey: "Text must be at least 15 characters"])))
            return
        }
        
        guard text.count <= 500 else {
            completion(.failure(NSError(domain: "", code: 400, 
                userInfo: [NSLocalizedDescriptionKey: "Text must be less than 500 characters"])))
            return
        }
        
        guard let url = URL(string: "\(IssueClassifier.baseURL)/api/classify") else {
            completion(.failure(NSError(domain: "", code: 500, 
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let body = ClassificationRequest(text: text)
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 500, 
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, 
                    userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            if httpResponse.statusCode == 429 {
                completion(.failure(NSError(domain: "", code: 429, 
                    userInfo: [NSLocalizedDescriptionKey: "Too many requests"])))
                return
            }
            
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, 
                        userInfo: [NSLocalizedDescriptionKey: errorResponse.error])))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ClassificationResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// Usage
let classifier = IssueClassifier()
classifier.classifyIssue(text: "My employer has not paid my salary for 3 months") { result in
    switch result {
    case .success(let response):
        print("Issue: \(response.issue_id)")
        print("Confidence: \(response.confidence)")
        
        if response.fallback {
            // Handle uncertain classification
            print("Warning: Low confidence classification")
        }
        
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Kotlin (Android)

```kotlin
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit

data class ClassificationResult(
    val issueId: String,
    val confidence: Double,
    val fallback: Boolean
)

class IssueClassifier {
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .build()

    companion object {
        private const val BASE_URL = "https://know-your-right-backend.onrender.com"
    }

    fun classifyIssue(text: String, callback: (Result<ClassificationResult>) -> Unit) {
        // Validate input
        if (text.length < 15) {
            callback(Result.failure(Exception("Text must be at least 15 characters")))
            return
        }
        if (text.length > 500) {
            callback(Result.failure(Exception("Text must be less than 500 characters")))
            return
        }

        val json = JSONObject().apply {
            put("text", text)
        }

        val mediaType = "application/json; charset=utf-8".toMediaType()
        val body = json.toString().toRequestBody(mediaType)

        val request = Request.Builder()
            .url("$BASE_URL/api/classify")
            .post(body)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback(Result.failure(e))
            }

            override fun onResponse(call: Call, response: Response) {
                response.use {
                    if (response.code == 429) {
                        callback(Result.failure(Exception("Too many requests. Please try again later.")))
                        return
                    }

                    val responseBody = response.body?.string()
                    if (!response.isSuccessful || responseBody == null) {
                        val error = responseBody?.let { 
                            JSONObject(it).optString("error", "Classification failed") 
                        } ?: "Classification failed"
                        callback(Result.failure(Exception(error)))
                        return
                    }

                    try {
                        val jsonResponse = JSONObject(responseBody)
                        val result = ClassificationResult(
                            issueId = jsonResponse.getString("issue_id"),
                            confidence = jsonResponse.getDouble("confidence"),
                            fallback = jsonResponse.getBoolean("fallback")
                        )
                        callback(Result.success(result))
                    } catch (e: Exception) {
                        callback(Result.failure(e))
                    }
                }
            }
        })
    }
}

// Usage
val classifier = IssueClassifier()
classifier.classifyIssue("My landlord is refusing to fix the broken plumbing") { result ->
    result.onSuccess { classification ->
        println("Issue: ${classification.issueId}")
        println("Confidence: ${classification.confidence}")
        
        if (classification.fallback) {
            // Show warning to user
            showToast("Could not determine exact issue category")
        }
    }.onFailure { error ->
        println("Error: ${error.message}")
        showToast("Failed to classify issue: ${error.message}")
    }
}
```

---

## 🧪 Testing the API

### cURL Command
```bash
curl -X POST https://know-your-right-backend.onrender.com/api/classify \
  -H "Content-Type: application/json" \
  -d '{"text": "My employer has not paid my salary for 3 months"}'
```

### Expected Response
```json
{
  "issue_id": "salary_not_paid",
  "confidence": 0.95,
  "fallback": false
}
```

---

## 🔒 Security Best Practices

1. **Input Validation**: Always validate user input on client-side before sending
   - Min 15 characters
   - Max 500 characters
   - Trim whitespace

2. **Rate Limiting**: Implement client-side rate limiting to avoid hitting the 20 req/min limit
   - Cache results when possible
   - Debounce API calls
   - Show loading states

3. **Error Handling**: Always handle all possible error cases
   - Network errors
   - Timeout errors
   - Validation errors
   - Rate limit errors

4. **Timeout**: Set reasonable timeout values (10 seconds recommended)

5. **User Experience**:
   - Show loading indicators during API calls
   - Display helpful error messages
   - Handle "unknown" classifications gracefully
   - Warn users about low-confidence classifications

---

## 📊 Response Confidence Interpretation

| Confidence Range | Interpretation | Action |
|-----------------|----------------|--------|
| 0.9 - 1.0 | Very High | Direct user to specific legal resource |
| 0.7 - 0.89 | High | Show category with confidence indicator |
| 0.6 - 0.69 | Medium | Show category with "verify details" prompt |
| < 0.6 | Low | Returns "unknown", prompt for more details |

---

## 🐛 Common Issues & Solutions

### Issue: "Too many requests" error
**Solution**: Implement request debouncing and local caching

### Issue: Slow response times
**Solution**: Show loading indicator, set reasonable timeouts (10s)

### Issue: "Text must be at least 15 characters"
**Solution**: Validate input length before API call

### Issue: Classification returns "unknown"
**Solution**: Prompt user to provide more specific details

---

## 📱 Recommended User Flow

1. **User Input**: Collect legal issue description (min 15 chars)
2. **Client Validation**: Check length constraints
3. **Show Loading**: Display spinner/progress indicator
4. **API Call**: Send request to `/api/classify`
5. **Handle Response**:
   - If `fallback: true` → Ask for more details
   - If `fallback: false` → Navigate to issue-specific screen
6. **Error Handling**: Show friendly error messages

---

## 💡 Example User Flow Implementation

```javascript
// React Native example
const SubmitIssueScreen = () => {
  const [issueText, setIssueText] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async () => {
    // Client-side validation
    if (issueText.trim().length < 15) {
      setError('Please provide more details about your legal issue (at least 15 characters)');
      return;
    }

    if (issueText.length > 500) {
      setError('Description is too long. Please keep it under 500 characters.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await fetch('https://know-your-right-backend.onrender.com/api/classify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: issueText.trim() }),
        timeout: 10000,
      });

      if (response.status === 429) {
        throw new Error('Please wait a moment before submitting again');
      }

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to process your request');
      }

      const result = await response.json();

      if (result.fallback) {
        // Low confidence - ask for more details
        Alert.alert(
          'Need More Information',
          'We need a bit more details to better understand your issue. Could you please elaborate?',
          [
            { text: 'Edit Description', style: 'cancel' },
            { text: 'Continue Anyway', onPress: () => navigateToIssue(result.issue_id) }
          ]
        );
      } else {
        // High confidence - proceed
        navigateToIssue(result.issue_id, result.confidence);
      }
    } catch (err) {
      setError(err.message);
      Alert.alert('Error', err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View>
      <TextInput
        value={issueText}
        onChangeText={setIssueText}
        placeholder="Describe your legal issue..."
        multiline
        maxLength={500}
      />
      <Text>{issueText.length}/500 characters</Text>
      
      {error && <Text style={styles.error}>{error}</Text>}
      
      <Button 
        title={loading ? "Analyzing..." : "Submit"} 
        onPress={handleSubmit}
        disabled={loading || issueText.trim().length < 15}
      />
    </View>
  );
};
```

---

## 🎯 Support

- **Backend Repository**: https://github.com/SarthakRay26/Know-Your-Right-backend
- **API Base URL**: https://know-your-right-backend.onrender.com
- **Rate Limit**: 20 requests/minute per IP
- **Response Time**: ~2-5 seconds

---

## 📝 License

This API is part of the "Know Your Rights" legal awareness application.
