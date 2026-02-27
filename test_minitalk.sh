#!/bin/bash

# =============================================================
# Tests minitalk - Exigences du sujet 42 uniquement
# =============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

PASS=0
FAIL=0
TOTAL=0

SERVER_OUTPUT=$(mktemp)

cleanup() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null
        wait "$SERVER_PID" 2>/dev/null
    fi
    rm -f "$SERVER_OUTPUT"
}
trap cleanup EXIT

run_test() {
    local test_name="$1"
    local message="$2"
    local expected="$3"
    local timeout_val="${4:-2}"

    TOTAL=$((TOTAL + 1))
    local size_before=$(wc -c < "$SERVER_OUTPUT")

    ./client "$SERVER_PID" "$message" 2>/dev/null
    sleep "$timeout_val"

    local size_after=$(wc -c < "$SERVER_OUTPUT")
    local new_bytes=$((size_after - size_before))
    local received=$(tail -c "$new_bytes" "$SERVER_OUTPUT" | tr -d '\n')

    if [ "$received" = "$expected" ]; then
        echo -e "  ${GREEN}✓ PASS${NC} - $test_name"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}✗ FAIL${NC} - $test_name"
        echo -e "    ${YELLOW}Attendu:${NC} $(echo -n "$expected" | head -c 80)"
        echo -e "    ${YELLOW}Reçu:   ${NC} $(echo -n "$received" | head -c 80)"
        FAIL=$((FAIL + 1))
    fi
}

echo -e "${BOLD}${CYAN}=============================================${NC}"
echo -e "${BOLD}${CYAN}   TESTS MINITALK - SUJET 42                ${NC}"
echo -e "${BOLD}${CYAN}=============================================${NC}"
echo ""

# ---------------------------------------------------------------
# 1. Compilation
# ---------------------------------------------------------------
echo -e "${BOLD}[1] Compilation${NC}"
TOTAL=$((TOTAL + 1))
if [ -f "./server" ] && [ -f "./client" ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - server et client compilés"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - Binaires manquants"
    FAIL=$((FAIL + 1))
    exit 1
fi

# Start server
> "$SERVER_OUTPUT"
./server > "$SERVER_OUTPUT" 2>&1 &
SERVER_PID=$!
sleep 0.5

# ---------------------------------------------------------------
# 2. Affichage du PID au lancement
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[2] Affichage du PID${NC}"
TOTAL=$((TOTAL + 1))
if grep -q "PID" "$SERVER_OUTPUT"; then
    echo -e "  ${GREEN}✓ PASS${NC} - Le serveur affiche son PID"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - Le serveur n'affiche pas son PID"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------
# 3. Transmission de messages (exigence principale du sujet)
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[3] Transmission de messages${NC}"
run_test "Message court" "Hello" "Hello"
run_test "Un seul caractère" "A" "A"
run_test "Chiffres" "42" "42"
run_test "Message avec espaces" "Hello World" "Hello World"
run_test "Phrase complète" "Le projet minitalk de 42 est super cool!" "Le projet minitalk de 42 est super cool!"

# ---------------------------------------------------------------
# 4. Message de 100 caractères (benchmark du sujet : < 1s)
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[4] Message de 100 caractères (benchmark sujet : < 1s)${NC}"
TOTAL=$((TOTAL + 1))
MSG100=$(python3 -c "print('A' * 100, end='')")
size_before=$(wc -c < "$SERVER_OUTPUT")
START=$(date +%s%N)
./client "$SERVER_PID" "$MSG100" 2>/dev/null
END=$(date +%s%N)
sleep 1
size_after=$(wc -c < "$SERVER_OUTPUT")
new_bytes=$((size_after - size_before))
received=$(tail -c "$new_bytes" "$SERVER_OUTPUT" | tr -d '\n')
elapsed_ms=$(( (END - START) / 1000000 ))

if [ "$received" = "$MSG100" ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - 100 chars reçus correctement (${elapsed_ms}ms)"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - 100 chars mal reçus (${#received} chars reçus)"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------
# 5. Messages consécutifs sans redémarrer le serveur
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[5] Messages consécutifs (sans redémarrer le serveur)${NC}"
TOTAL=$((TOTAL + 1))
size_before=$(wc -c < "$SERVER_OUTPUT")

./client "$SERVER_PID" "premier"
sleep 0.5
./client "$SERVER_PID" "deuxieme"
sleep 0.5
./client "$SERVER_PID" "troisieme"
sleep 1

size_after=$(wc -c < "$SERVER_OUTPUT")
new_bytes=$((size_after - size_before))
received=$(tail -c "$new_bytes" "$SERVER_OUTPUT")
count=0
echo "$received" | grep -q "premier" && count=$((count + 1))
echo "$received" | grep -q "deuxieme" && count=$((count + 1))
echo "$received" | grep -q "troisieme" && count=$((count + 1))

if [ "$count" -eq 3 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - 3 messages consécutifs reçus"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - $count/3 messages reçus"
    echo -e "    ${YELLOW}Reçu:${NC} $(echo "$received" | tr '\n' '|')"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------
# 6. Gestion d'erreurs du client
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[6] Gestion d'erreurs${NC}"

TOTAL=$((TOTAL + 1))
./client 2>/dev/null
ret=$?
if [ $ret -ne 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - Sans arguments → erreur"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - Sans arguments devrait retourner erreur"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
./client 0 "test" 2>/dev/null
ret=$?
if [ $ret -ne 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - PID invalide → erreur"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - PID invalide devrait retourner erreur"
    FAIL=$((FAIL + 1))
fi

TOTAL=$((TOTAL + 1))
./client -1 "test" 2>/dev/null
ret=$?
if [ $ret -ne 0 ]; then
    echo -e "  ${GREEN}✓ PASS${NC} - PID négatif → erreur"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - PID négatif devrait retourner erreur"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------
# 7. Serveur toujours actif après tous les tests
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}[7] Serveur toujours actif${NC}"
TOTAL=$((TOTAL + 1))
if kill -0 "$SERVER_PID" 2>/dev/null; then
    echo -e "  ${GREEN}✓ PASS${NC} - Serveur toujours en vie après tous les tests"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}✗ FAIL${NC} - Le serveur a crashé"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------
# RÉSUMÉ
# ---------------------------------------------------------------
echo ""
echo -e "${BOLD}${CYAN}=============================================${NC}"
echo -e "${BOLD}${CYAN}   RÉSUMÉ                                   ${NC}"
echo -e "${BOLD}${CYAN}=============================================${NC}"
echo -e "  Total:   ${BOLD}$TOTAL${NC}"
echo -e "  ${GREEN}Réussis: $PASS${NC}"
echo -e "  ${RED}Échoués: $FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}  Tous les tests du sujet sont OK !${NC}"
else
    echo -e "${YELLOW}${BOLD}  $FAIL test(s) échoué(s) sur $TOTAL${NC}"
fi
echo ""
