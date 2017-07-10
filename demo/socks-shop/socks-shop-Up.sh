#!/bin/bash



################################################################################################

# Create Networks

################################################################################################

networks=(ms-net)

for network in "${networks[@]}"

do

  networkFound=$(docker network ls --filter name=$network | awk '{print $2}' |grep $network|wc -l)

    if [ $networkFound -eq 1 ]; then

        echo "[ NETWORK IS FOUND ] $network"

          else

              echo "[ CREATING NETWORK ] $network"

                  docker network create --driver overlay $network

                      sleep 4s

                        fi

                        done



                        echo "Creating the [front-end-ms] service"

                        docker service create \

                                --name front-end \

                                        --network ms-net \

                                                ekambaram/front-end-ms:v1



                                                echo "Creating the proxy and load balancer [edge-router-ms] service"

                                                docker service create \

                                                        --name edge-router \

                                                                --publish 80:80 \

                                                                        --network ms-net \

                                                                                ekambaram/edge-router-ms:v1



                                                                                echo "Creating the [catalogue-ms] service"

                                                                                docker service create \

                                                                                        --name catalogue \

                                                                                                --network ms-net \

                                                                                                        ekambaram/catalogue-ms:v1



                                                                                                        echo "Creating the [catalogue-db-ms] service"

                                                                                                        docker service create \

                                                                                                                --name catalogue-db \

                                                                                                                        --network ms-net \

                                                                                                                                -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \

                                                                                                                                        -e MYSQL_ALLOW_EMPTY_PASSWORD=true \

                                                                                                                                                -e MYSQL_DATABASE=socksdb \

                                                                                                                                                        ekambaram/catalogue-db-ms:v1



                                                                                                                                                        echo "Creating the [cart-ms] service"

                                                                                                                                                        docker service create \

                                                                                                                                                                --name cart \

                                                                                                                                                                        --network ms-net \

                                                                                                                                                                                ekambaram/cart-ms:v1



                                                                                                                                                                                echo "Creating the [cart-db-ms] mongo service"

                                                                                                                                                                                docker service create \

                                                                                                                                                                                        --name cart-db \

                                                                                                                                                                                                --network ms-net \

                                                                                                                                                                                                        mongo



                                                                                                                                                                                                        echo "Creating the [orders-ms] service"

                                                                                                                                                                                                        docker service create \

                                                                                                                                                                                                                --name orders \

                                                                                                                                                                                                                        --network ms-net \

                                                                                                                                                                                                                                ekambaram/orders-ms:v1



                                                                                                                                                                                                                                echo "Creating the [orders-db-ms] mongo service"

                                                                                                                                                                                                                                docker service create \

                                                                                                                                                                                                                                        --name orders-db \

                                                                                                                                                                                                                                                --network ms-net \

                                                                                                                                                                                                                                                        mongo



                                                                                                                                                                                                                                                        echo "Creating the [shipping-ms] service"

                                                                                                                                                                                                                                                        docker service create \

                                                                                                                                                                                                                                                                --name shipping \

                                                                                                                                                                                                                                                                        --network ms-net \

                                                                                                                                                                                                                                                                                ekambaram/shipping-ms:v1



                                                                                                                                                                                                                                                                                echo "Creating the [rabbitmq] service"

                                                                                                                                                                                                                                                                                docker service create \

                                                                                                                                                                                                                                                                                        --name rabbitmq \

                                                                                                                                                                                                                                                                                                --network ms-net \

                                                                                                                                                                                                                                                                                                        rabbitmq:3



                                                                                                                                                                                                                                                                                                        echo "Creating the [payment-ms] service"

                                                                                                                                                                                                                                                                                                        docker service create \

                                                                                                                                                                                                                                                                                                                --name payment \

                                                                                                                                                                                                                                                                                                                        --network ms-net \

                                                                                                                                                                                                                                                                                                                                ekambaram/payment-ms:v1



                                                                                                                                                                                                                                                                                                                                echo "Creating the [user-ms] service"

                                                                                                                                                                                                                                                                                                                                docker service create \

                                                                                                                                                                                                                                                                                                                                        --name user \

                                                                                                                                                                                                                                                                                                                                                --network ms-net \

                                                                                                                                                                                                                                                                                                                                                        -e MONGO_HOST=user-db:27017 \

                                                                                                                                                                                                                                                                                                                                                                ekambaram/user-ms:v1



                                                                                                                                                                                                                                                                                                                                                                echo "Creating the [user-db-ms] service"

                                                                                                                                                                                                                                                                                                                                                                docker service create \

                                                                                                                                                                                                                                                                                                                                                                        --name user-db \

                                                                                                                                                                                                                                                                                                                                                                                --network ms-net \

                                                                                                                                                                                                                                                                                                                                                                                        ekambaram/user-db-ms:v1


