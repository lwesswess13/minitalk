# Minitalk

Communication entre processus via signaux UNIX.

## Compilation

```bash
make        # Compile server et client
make bonus  # Compile les versions bonus
make clean  # Supprime les .o
make fclean # Supprime tout
make re     # Recompile tout
```

## Utilisation

### 1. Lancer le serveur
```bash
./server
# Affiche: Server PID: 12345
```

### 2. Envoyer un message
```bash
./client 12345 "Hello World!"
```

### Version Bonus
```bash
./server_bonus
./client_bonus 12345 "Hello!"
# Affiche: Message received by server!
```

## Tests rapides

```bash
# Test basique
./client <PID> "Bonjour"

# Caractères spéciaux
./client <PID> 'Test !@#$%^&*()'

# Message long
./client <PID> 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'

# Erreur: sans arguments
./client

# Erreur: PID invalide
./client -1 test
./client 99999999 test
```

---

## Notions à comprendre

### 1. Signaux UNIX
Les signaux sont des interruptions logicielles envoyées à un processus.
- `SIGUSR1` et `SIGUSR2` : signaux personnalisables par l'utilisateur
- `kill(pid, signal)` : envoie un signal à un processus
- `sigaction()` : configure comment réagir à un signal

### 2. Communication bit par bit
Chaque caractère (8 bits) est envoyé un bit à la fois :
- **SIGUSR1** = bit à 1
- **SIGUSR2** = bit à 0

Exemple pour 'A' (ASCII 65 = `01000001`) :
```
Bit 0: 1 → SIGUSR1
Bit 1: 0 → SIGUSR2
Bit 2: 0 → SIGUSR2
...
```

### 3. Opérations binaires
```c
c |= (1 << bit);  // Met le bit à 1
(c >> bit) & 1    // Lit le bit
```

### 4. Variables static
```c
static int bit = 0;  // Garde sa valeur entre les appels
```

### 5. PID (Process ID)
Chaque processus a un identifiant unique. `getpid()` retourne le PID du processus courant.

### 6. sigaction vs signal
`sigaction()` est plus fiable que `signal()` :
- Comportement portable
- Plus d'options (SA_SIGINFO pour recevoir des infos sur l'expéditeur)

---

## Fichiers

| Fichier | Description |
|---------|-------------|
| `server.c` | Reçoit et affiche les messages |
| `client.c` | Envoie les messages bit par bit |
| `minitalk.h` | Header commun |
| `*_bonus.c` | Versions avec accusé de réception |
