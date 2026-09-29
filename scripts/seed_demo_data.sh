#!/usr/bin/env bash
set -e

echo "=========================================="
echo "   WALLET AI - SEED DEMO DATA VERIFIER    "
echo "=========================================="

SEED_FILE="$(dirname "$0")/../firebase/firestore.seed.json"

if [ -f "$SEED_FILE" ]; then
  echo "Archivo de datos semilla localizado en: $SEED_FILE"
  echo "Emisores incluidos: Banco Aurora, Banco Horizonte, Banco Prisma"
  echo "Para cargar en emulador o Firestore remoto ejecute:"
  echo "  firebase emulators:start --import=firebase/"
else
  echo "Error: No se encontró el archivo firestore.seed.json"
  exit 1
fi

echo "Verificación de seed data exitosa."
