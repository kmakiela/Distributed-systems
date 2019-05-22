.PHONY: run-server run-server2 run-client run-exchange

bank_ice:
	mkdir -p ./utils/out/ice; \
	slice2py --output-dir ./utils/out/ice ./utils/bank.ice

exchange_java:
	cd exchange; \
	./gradlew build

exchange_python:
	mkdir -p ./utils/out/proto; \
	python3 -m grpc_tools.protoc -I./utils --python_out=./utils/out/proto --grpc_python_out=./utils/out/proto ./utils/exchange.proto

run-server:
	python3 ./bank/server.py ./bank/config.server 1 2 3

run-server2:
	python3 ./bank/server.py ./bank/config2.server 0 3 4

run-client:
	python3 ./client/client.py

run-exchange:
	cd exchange; \
	./gradlew run
