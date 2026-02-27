/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sbouchib <sbouchib@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/25 10:00:00 by lwesswess         #+#    #+#             */
/*   Updated: 2026/02/27 10:30:12 by sbouchib         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

static char	*ft_grow(char *old, int old_len, int new_cap)
{
	char	*new;
	int		i;

	new = malloc(new_cap);
	if (!new)
	{
		free(old);
		return (NULL);
	}
	i = 0;
	while (i < old_len)
	{
		new[i] = old[i];
		i++;
	}
	free(old);
	return (new);
}

static void	flush_buf(t_buf *buf)
{
	if (buf->str)
	{
		write(1, buf->str, buf->len);
		free(buf->str);
		buf->str = NULL;
	}
	write(1, "\n", 1);
	buf->len = 0;
	buf->cap = 0;
}

static void	append_buf(t_buf *buf, char c)
{
	if (buf->len >= buf->cap)
	{
		if (buf->cap == 0)
			buf->cap = 128;
		else
			buf->cap *= 2;
		buf->str = ft_grow(buf->str, buf->len, buf->cap);
		if (!buf->str)
		{
			buf->len = 0;
			buf->cap = 0;
			return ;
		}
	}
	buf->str[buf->len] = c;
	buf->len++;
}

static void	signal_handler(int signum, siginfo_t *info, void *context)
{
	static int		bit = 0;
	static int		c = 0;
	static t_buf	buf;

	(void)context;
	if (signum == SIGUSR1)
		c |= (1 << bit);
	bit++;
	if (bit == 8)
	{
		if (c == '\0')
			flush_buf(&buf);
		else
			append_buf(&buf, c);
		bit = 0;
		c = 0;
	}
	kill(info->si_pid, SIGUSR1);
}

int	main(void)
{
	struct sigaction	sa;

	ft_putstr("Server PID: ");
	ft_putnbr(getpid());
	ft_putchar('\n');
	sa.sa_sigaction = signal_handler;
	sa.sa_flags = SA_SIGINFO;
	sigemptyset(&sa.sa_mask);
	sigaddset(&sa.sa_mask, SIGUSR1);
	sigaddset(&sa.sa_mask, SIGUSR2);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
	{
		ft_putstr("Error: sigaction failed\n");
		return (1);
	}
	if (sigaction(SIGUSR2, &sa, NULL) == -1)
	{
		ft_putstr("Error: sigaction failed\n");
		return (1);
	}
	while (1)
		pause();
	return (0);
}
