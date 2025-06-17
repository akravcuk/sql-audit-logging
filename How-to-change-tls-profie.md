1. findout obsolete TLS profily
```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| project TimeGenerated, clientIP_s, requestUri_s, sslCipher_s, sslProtocol_s
| summarize by sslCipher_s

// Result:
ECDHE-RSA-AES256-GCM-SHA384
ECDHE-RSA-AES128-GCM-SHA256
ECDHE-RSA-AES128-SHA256
ECDHE-RSA-AES256-SHA
```

2. Findout iunique IPs that use obsolete TLS profiles
```kusto
AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| project TimeGenerated, clientIP_s, sslCipher_s
| summarize UniqueIPs=dcount(clientIP_s) by sslCipher_s
| order by UniqueIPs desc

// Result:
ECDHE-RSA-AES256-GCM-SHA384 340
ECDHE-RSA-AES128-GCM-SHA256 177
ECDHE-RSA-AES128-SHA256     4
ECDHE-RSA-AES256-SHA        3
```

3. Findout the amount of requests per obsolete TLS profile per IPs
```kusto
let WeakCiphers = dynamic([
  "ECDHE-RSA-AES128-SHA256",
  "ECDHE-RSA-AES256-SHA",
  "ECDHE-RSA-AES128-SHA",
  "ECDHE-RSA-AES256-CBC-SHA",
  "TLS_RSA_WITH_AES_128_CBC_SHA",
  "TLS_RSA_WITH_AES_256_CBC_SHA"
]);

AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| where TimeGenerated > ago(30d)
| where isnotempty(sslCipher_s)
| where sslCipher_s in (WeakCiphers)
| summarize Requests=count(), UniqueIPs=dcount(clientIP_s) by sslCipher_s, sslProtocol_s
| order by Requests desc

// Result:
sslCipher_s	            sslProtocol_s	Requests	UniqueIPs
ECDHE-RSA-AES256-SHA	TLSv1	        8	        8
ECDHE-RSA-AES256-SHA	TLSv1.1	        8	        8
ECDHE-RSA-AES128-SHA256	TLSv1.2	        6	        5
ECDHE-RSA-AES256-SHA	TLSv1.2	        1	        1
```

4. get unique IPs that use obsolete TLS profiles
```kusto
let WeakCiphers = dynamic([
  "ECDHE-RSA-AES128-SHA256",
  "ECDHE-RSA-AES256-SHA",
  "ECDHE-RSA-AES128-SHA",
  "TLS_RSA_WITH_AES_128_CBC_SHA",
  "TLS_RSA_WITH_AES_256_CBC_SHA"
]);

AzureDiagnostics
| where ResourceType == "APPLICATIONGATEWAYS"
| where Category == "ApplicationGatewayAccessLog"
| where TimeGenerated > ago(30d)
| where sslCipher_s in (WeakCiphers)
| project TimeGenerated, clientIP_s, sslCipher_s, sslProtocol_s
| summarize Count = count() by clientIP_s, sslCipher_s, sslProtocol_s
| order by Count desc
```
Result:
| clientIP_s       | sslCipher_s              | sslProtocol_s | Count |
|------------------|--------------------------|----------------|-------|
| 157.230.227.116  | ECDHE-RSA-AES128-SHA256  | TLSv1.2        | 2     |
| 86.54.31.38      | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 86.54.31.38      | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 86.54.31.34      | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 143.198.126.242  | ECDHE-RSA-AES128-SHA256  | TLSv1.2        | 1     |
| 86.54.31.34      | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 2.59.22.234      | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 66.240.219.146   | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 66.240.219.146   | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 194.50.16.252    | ECDHE-RSA-AES128-SHA256  | TLSv1.2        | 1     |
| 80.82.77.33      | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 80.82.77.33      | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 2.59.22.234      | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 143.244.175.80   | ECDHE-RSA-AES128-SHA256  | TLSv1.2        | 1     |
| 134.209.215.32   | ECDHE-RSA-AES256-SHA     | TLSv1.2        | 1     |
| 161.35.98.92     | ECDHE-RSA-AES128-SHA256  | TLSv1.2        | 1     |
| 80.82.77.139     | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 80.82.77.139     | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 71.6.146.186     | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 71.6.146.186     | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |
| 71.6.167.142     | ECDHE-RSA-AES256-SHA     | TLSv1.1        | 1     |
| 71.6.167.142     | ECDHE-RSA-AES256-SHA     | TLSv1          | 1     |

5. Geographical location of IPs that use obsolete TLS profiles
```python
import requests

with open("ips.txt", "r") as f:
    ips = [line.strip() for line in f if line.strip()]

for ip in ips:
    try:
        r = requests.get(f"https://ipinfo.io/{ip}/json")
        data = r.json()
        print(f"{ip}: {data.get('city', 'N/A')}, {data.get('region', 'N/A')}, {data.get('country', 'N/A')} — {data.get('org', 'N/A')}")
    except Exception as e:
        print(f"{ip}: Error - {e}")
```
5.2 ips.txt
```
157.230.227.116
2.59.22.234
66.240.219.146
86.54.31.38
194.50.16.252
80.82.77.33
71.6.146.186
143.198.126.242
143.244.175.80
134.209.215.32
161.35.98.92
86.54.31.34
80.82.77.139
71.6.167.142
```
5.3 Result:
python ./ip-test-.py
| IP Address        | City              | Region         | Country | ASN / Organization                  |
|-------------------|-------------------|----------------|---------|-------------------------------------|
| 157.230.227.116   | North Bergen      | New Jersey     | US      | AS14061 DigitalOcean, LLC           |
| 2.59.22.234       | Vienna            | Vienna         | AT      | AS174 Cogent Communications         |
| 66.240.219.146    | San Diego         | California     | US      | AS10439 CariNet, Inc                |
| 86.54.31.38       | Amsterdam         | North Holland  | NL      | AS174 Cogent Communications         |
| 194.50.16.252     | Lelystad          | Flevoland      | NL      | AS49870 Alsycon B.V.                |
| 80.82.77.33       | Amsterdam         | North Holland  | NL      | AS202425 IP Volume inc              |
| 71.6.146.186      | San Diego         | California     | US      | AS10439 CariNet, Inc                |
| 143.198.126.242   | North Bergen      | New Jersey     | US      | AS14061 DigitalOcean, LLC           |
| 143.244.175.80    | North Bergen      | New Jersey     | US      | AS14061 DigitalOcean, LLC           |
| 134.209.215.32    | North Bergen      | New Jersey     | US      | AS14061 DigitalOcean, LLC           |
| 161.35.98.92      | North Bergen      | New Jersey     | US      | AS14061 DigitalOcean, LLC           |
| 86.54.31.34       | Amsterdam         | North Holland  | NL      | AS174 Cogent Communications         |
| 80.82.77.139      | Amsterdam         | North Holland  | NL      | AS202425 IP Volume inc              |
| 71.6.167.142      | San Diego         | California     | US      | AS10439 CariNet, Inc                |
