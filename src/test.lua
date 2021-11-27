http = require "http.request"

function main()
    API_ENDPOINT = "https://api.github.com"


    api_query = API_ENDPOINT.."/users/alexypdu/gists"
    print(api_query)
    response = http.get(api_query).readAll()
    print(response)
end

main()