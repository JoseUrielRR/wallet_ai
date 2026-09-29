#!/usr/bin/env bash
set -e

echo "=========================================="
echo "      WALLET AI - SETUP DEL PROYECTO      "
echo "=========================================="

echo "[1/3] Verificando dependencias en app/..."
cd "$(dirname "$0")/../app"
flutter pub get

echo "[2/3] Ejecutando análisis estático..."
flutter analyze

echo "[3/3] Ejecutando pruebas unitarias del motor financiero..."
flutter test

echo ""
echo "=========================================="
echo "   ¡Setup completado satisfactoriamente!  "
echo "=========================================="
