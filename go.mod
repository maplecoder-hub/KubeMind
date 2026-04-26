module github.com/kubemind/kubemind

go 1.22

require (
	sigs.k8s.io/controller-runtime v0.17.2
	k8s.io/client-go v0.29.0
	k8s.io/apimachinery v0.29.0
	k8s.io/api v0.29.0
	github.com/go-logr/logr v1.4.1
	github.com/segmentio/kafka-go v0.4.47
	github.com/redis/go-redis/v9 v9.5.1
	github.com/jackc/pgx/v5 v5.5.5
	google.golang.org/grpc v1.63.2
	google.golang.org/protobuf v1.34.1
	github.com/spf13/cobra v1.8.0
	github.com/spf13/viper v1.18.2
)