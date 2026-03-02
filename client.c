/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sbouchib <sbouchib@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/25 10:00:00 by lwesswess         #+#    #+#             */
/*   Updated: 2026/03/02 10:48:53 by sbouchib         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

volatile int	g_ack = 0;

static void	ack_handler(int signum)
{
	(void)signum;
	g_ack = 1;
}

static void	ft_putstr_error(char *str)
{
	while (*str)
		write(2, str++, 1);
}

static void	send_char(int pid, char c)
{
	int	bit;

	bit = 0;
	while (bit < 8)
	{
		g_ack = 0;
		if ((c >> bit) & 1)
			kill(pid, SIGUSR1);
		else
			kill(pid, SIGUSR2);
		while (!g_ack)
			usleep(200);
		bit++;
	}
}

int	main(int argc, char **argv)
{
	struct sigaction	sa;
	int					pid;
	int					i;

	if (argc != 3)
	{
		ft_putstr_error("Usage: ./client [server_pid] [message]\n");
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
	sigaction(SIGUSR1, &sa, NULL);
	i = 0;
	while (argv[2][i])
		send_char(pid, argv[2][i++]);
	send_char(pid, '\0');
	return (0);
}
