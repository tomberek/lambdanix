.PHONY: create bundle update invoke

create: function.zip
	aws lambda create-function --function-name nix-runner --zip-file fileb://function.zip --runtime provided --role $(shell cat .arn) --handler dummy

bundle: function.zip

function.zip:
	nix-build -o function.zip

update: function.zip
	aws lambda update-function-code --function-name nix-runner --zip-file fileb://function.zip
	aws lambda update-function-configuration --function-name nix-runner --memory-size 1024

invoke: out.nar
	aws lambda invoke --function-name nix-runner --payload $$(cat out.nar | base64 -w0 | jq -Rn 'input') response.txt ; cat response.txt

out.nar:
	nix-store --export $(nix-instantiate src/default.nix | xargs nix-store -qR) > out.nar

clean:
	rm -f function.zip result out.nar response.txt
