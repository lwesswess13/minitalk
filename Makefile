# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::   #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lwesswess <lwesswess@student.42.fr>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/25 10:00:00 by lwesswess         #+#    #+#              #
#    Updated: 2026/01/25 10:00:00 by lwesswess        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

CC = cc
CFLAGS = -Wall -Wextra -Werror

SERVER = server
CLIENT = client
SERVER_BONUS = server_bonus
CLIENT_BONUS = client_bonus

SERVER_SRC = server.c
CLIENT_SRC = client.c
SERVER_BONUS_SRC = server_bonus.c
CLIENT_BONUS_SRC = client_bonus.c

SERVER_OBJ = $(SERVER_SRC:.c=.o)
CLIENT_OBJ = $(CLIENT_SRC:.c=.o)
SERVER_BONUS_OBJ = $(SERVER_BONUS_SRC:.c=.o)
CLIENT_BONUS_OBJ = $(CLIENT_BONUS_SRC:.c=.o)
UTILS_BONUS_OBJ = utils_bonus.o

all: $(SERVER) $(CLIENT)

$(SERVER): $(SERVER_OBJ)
	$(CC) $(CFLAGS) -o $(SERVER) $(SERVER_OBJ)

$(CLIENT): $(CLIENT_OBJ)
	$(CC) $(CFLAGS) -o $(CLIENT) $(CLIENT_OBJ)

$(SERVER_BONUS): $(SERVER_BONUS_OBJ)
	$(CC) $(CFLAGS) -o $(SERVER_BONUS) $(SERVER_BONUS_OBJ)

$(CLIENT_BONUS): $(CLIENT_BONUS_OBJ) $(UTILS_BONUS_OBJ)
	$(CC) $(CFLAGS) -o $(CLIENT_BONUS) $(CLIENT_BONUS_OBJ) $(UTILS_BONUS_OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

bonus: $(SERVER_BONUS) $(CLIENT_BONUS)

clean:
	rm -f $(SERVER_OBJ) $(CLIENT_OBJ) $(SERVER_BONUS_OBJ) $(CLIENT_BONUS_OBJ) $(UTILS_BONUS_OBJ)

fclean: clean
	rm -f $(SERVER) $(CLIENT) $(SERVER_BONUS) $(CLIENT_BONUS)

re: fclean all

.PHONY: all clean fclean re bonus
