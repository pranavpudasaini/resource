## Sensitive Data Regex List

```bash
# Generic credential
".*[a|A][u|U][t|T][h|H].*" #auth
".*[a|A][c|C][c|C][e|E][s|S][s|S].*" #access
".*[a|A][u|U][t|H][o|O][r|R][i|I].*"
".*[c|C][r|R][e|E][d|D][e|E][n|N][t|T][i|I][a|A][l|L].*"
".*[t|T][o|O][k|K][e|E][n|N].*" #token
".*[k|K][e|E][y|Y].*" #key
".*[s|E][e|E][c|C][r|R][e|E][t|T].*"
".*[u|U][s|S][e|E][r|R].*" #user
".*[p|P][a|A][s|S][s|S][w|W][o|O][r|R][d|D].*" #password
".*[p|P][a|A][s|S][s|S][w|W][d|D].*" #passwd

# Generic credential 2
"[0-9a-zA-Z*-_/+]{20,80}"

# Private key (rsa, dsa, ec, pgp)
"(——-(BEGIN|END) PRIVATE KEY——-)"
"(——-(BEGIN|END) RSA PRIVATE KEY——-)"
"(——-(BEGIN|END) EC PRIVATE KEY——-)"
"(——-(BEGIN|END) DSA PRIVATE KEY——-)"
"(——-(BEGIN|END) PGP PRIVATE KEY BLOCK——-)"

#------------------------------------------------------------------------------------------------#

# Amazon MWS Auth Token
"amzn\\.mws\\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

# AWS
"AKIA[0-9A-Z]{16}" 			#Access Key ID -- ex: AKIAVVOWJHRHxHFP4XU25
"[0-9a-zA-Z*-_/+]{20,80}"	# Secret Access Key -- ex: J+arI61t/VSXu/9IuESz9EhgIWwY1mPtTJ5YsSSB

# CircleCI	
"[0-9a-f]{40}"				# Access Token -- ex: 6ec46aff7cafbafe88eff5a52ebf3a58f1c95d6d

# Facebook OAuth access token
"[A-Za-z0-9]{125}" 			#OAuth Access Token

# Github access token -- ex: 960130c9a07dfade3de919ae1edbfb46237ea9ab
"[0-9a-zA-Z]{35,40}"

# Google 
"AIza[0-9A-Za-z*]{35}"	#API Key
"ya29\\.[0-9A-Za-z*]+" 	#OAuth Access Token

# Heroku API Key --ex: cf0e05d9-4eca-4948-a012-b91fe9704bab
"[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"

# MailChimp (API Key) -- ex: 3d48cffbc53992ec34584ffd9a87b94f-us19
"[0-9a-f]{32}-us[0-9]{1,2}"

# Mailgun API Key --ex: key-3ax6xnjp29jd6fds4gc373sgvjxteo10
"key-[0-9a-zA-Z]{32}"

# NPM auth token
"[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"

# Instagram OAuth Access Token --ex: fb2e77d.47a0479900504cb3ab4a1f626d174d2d
"[0-9a-fA-F]{7}\\.[0-9a-fA-F]{32}"

# Twilio
"(AC|AP)[a-zA-Z0-9]{32}" # Account/App SID --ex: AC4f196a7f59f8afcde4fa66e239de18eb
"SK[0-9a-fA-F]{32}" # API Key SID

# PayPal Braintree Access Token
"access_token\\$production\\$[0-9a-z]{16}\\$[0-9a-f]{32}"

# Picatic API Key
"sk_live_[0-9a-z]{32}"

# Slack Access Token
"(xox[p|b|o|a]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32})"

# SendGird API Key --ex: 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
"SG\\.[a-zA-Z0-9]{22}\\.[a-zA-Z0-9*-_]{43}"

# Stripe 
"sk_live_[0-9a-zA-Z]{24}" #API Key
"rk_live_[0-9a-zA-Z]{24}" #Restricted API Key

# Square (Acess Token, OAuth Secret)
"sq0atp-[0-9A-Za-z*]{22}" #Access Token
"sq0csp-[0-9A-Za-z*]{43}" #OAuth Secret


```