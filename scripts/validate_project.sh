#!/usr/bin/env bash
set -e

echo "=========================================="
echo "    WALLET AI - VALIDACIÓN INTEGRAL       "
echo "=========================================="

ROOT_DIR="$(dirname "$0")/.."

echo "1. Validando estructura de documentación en docs/..."
for doc in PROJECT_OVERVIEW.md ARCHITECTURE.md IMPLEMENTATION_PLAN.md DATABASE_SCHEMA.md BUSINESS_RULES.md UI_UX_SPECIFICATION.md SECURITY_PLAN.md TESTING_PLAN.md DECISIONS.md; do
  if [ ! -f "$ROOT_DIR/docs/$doc" ]; then
    echo "Falta documento obligatorio: docs/$doc"
    exit 1
  fi
done
echo "   -> Todos los documentos obligatorios presentes."

echo "2. Validando reglas de Firestore y configuración..."
if [ ! -f "$ROOT_DIR/firebase/firestore.rules" ] || [ ! -f "$ROOT_DIR/firebase.json" ]; then
  echo "Faltan reglas o configuración de Firebase"
  exit 1
fi
echo "   -> Reglas de Firestore verificadas."

echo "3. Ejecutando suite de pruebas unitarias y widgets..."
cd "$ROOT_DIR/app"
flutter test

echo ""
echo "=========================================="
echo "   ¡PROYECTO WALLET AI 100% VALIDADO!     "
echo "=========================================="
