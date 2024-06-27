package api

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-playground/validator/v10"
	db "github.com/itzaddddd/simple_bank/db/sqlc"
	"github.com/itzaddddd/simple_bank/token"
	"github.com/itzaddddd/simple_bank/util"
)

type Server struct {
	config     util.Config
	store      db.Store
	tokenMaker token.Maker
	router     *gin.Engine
}

func NewServer(config util.Config, store db.Store) (*Server, error) {
	tokenMaker, err := token.NewPasetoMaker(config.TokenSymmetricKey)
	if err != nil {
		return nil, fmt.Errorf("cannot create token maker: %v", err)
	}

	server := &Server{
		store:      store,
		tokenMaker: tokenMaker,
		config:     config,
	}

	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		server.SetupValidator(v)
	}

	server.SetupRouter()

	return server, nil
}

func (server *Server) SetupRouter() {
	router := gin.Default()

	authRutes := router.Group("/").Use(AuthMiddleware(server.tokenMaker))

	authRutes.POST("/account", server.CreateAccount)
	authRutes.GET("/account/:id", server.GetAccount)
	authRutes.GET("/accounts", server.ListAccount)

	authRutes.POST("/transfer", server.CreateTransfer)

	router.POST("/user", server.CreateUser)
	router.POST("/user/login", server.loginUser)

	server.router = router
}

func (server *Server) SetupValidator(validator *validator.Validate) {
	validator.RegisterValidation("currency", validCurrency)
}

// Start run the HTTP server on specific address
func (server *Server) Start(address string) error {
	return server.router.Run(address)
}

func errorResponse(err error) gin.H {
	return gin.H{"err": err.Error()}
}
