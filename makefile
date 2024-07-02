IMAGE=postgres16

postgres:
	docker run --name postgres16 --network bank-network -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=1234 -d postgres:16-alpine

createdb:
	docker exec -it postgres16 createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres16 dropdb simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://root:1234@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://root:1234@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migrateupaws:
	migrate -path db/migration -database "postgresql://root:VK26NIS1uOyEWWmCHj3c@simple-bank.cn20ua2mcmbe.ap-southeast-1.rds.amazonaws.com:5432/simple_bank" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://root:1234@localhost:5432/simple_bank?sslmode=disable" -verbose down

migratedown1:
	migrate -path db/migration -database "postgresql://root:1234@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

migratedownaws:
		migrate -path db/migration -database "postgresql://root:VK26NIS1uOyEWWmCHj3c@simple-bank.cn20ua2mcmbe.ap-southeast-1.rds.amazonaws.com/simple_bank" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...	

server:
	go run main.go

mock:
	mockgen --package mockdb -destination db/mock/store.go github.com/itzaddddd/simple_bank/db/sqlc Store

dockerbuild:
	docker build -t simplebank:lastest .

dockerrun:
	docker run --name simplebank --network bank-network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:1234@postgres16:5432/simple_bank?sslmode=disable" simplebank:lastest

.PHONY: postgres createdb dropdb  migrateup migratedown migrateup1 migratedown1 sqlc test server mock dockerbuild dockerrun