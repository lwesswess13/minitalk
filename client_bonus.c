/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sbouchib <sbouchib@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/25 10:00:00 by lwesswess         #+#    #+#             */
/*   Updated: 2026/01/30 17:14:41 by sbouchib         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk_bonus.h"

static int	g_ack_received = 0;

static void	ack_handler(int signum)
{
	(void)signum;
	g_ack_received = 1;
}

static void	send_bit(int pid, int bit)
{
	g_ack_received = 0;
	if (bit)
	{
		if (kill(pid, SIGUSR1) == -1)
		{
			ft_putstr_error("Error: kill failed\n");
			exit(1);
		}
	}
	else
	{
		if (kill(pid, SIGUSR2) == -1)
		{
			ft_putstr_error("Error: kill failed\n");
			exit(1);
		}
	}
	while (!g_ack_received)
		usleep(50);
}

static void	send_char(int pid, char c)
{
	int	bit;

	bit = 0;
	while (bit < 8)
	{
		send_bit(pid, (c >> bit) & 1);
		bit++;
	}
}

static void	send_message(int pid, char *str)
{
	while (*str)
	{
		send_char(pid, *str);
		str++;
	}
	send_char(pid, '\0');
	ft_putstr_fd("Message received by server!\n", 1);
}

int	main(int argc, char **argv)
{
	int					pid;
	struct sigaction	sa;

	if (argc != 3)
	{
		ft_putstr_error("Usage: ./client_bonus [server_pid] [message]\n");
		return (1);
	}
	pid = ft_atoi(argv[1]);
	if (pid <= 0)
	{
		ft_putstr_error("Error: Invalid PID\n");
		return (1);
	}
	sa.sa_handler = ack_handler;
	sa.sa_flags = 0;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
	{
		ft_putstr_error("Error: sigaction failed\n");
		return (1);
	}
	send_message(pid, argv[2]);
	return (0);
}
