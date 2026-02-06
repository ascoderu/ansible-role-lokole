#!/bin/bash
set -e

echo "🔍 Verifying Lokole installation..."

# Check supervisor services
echo "1. Checking supervisor services..."
if sudo supervisorctl status | grep lokole | grep -q RUNNING; then
    SERVICES=$(sudo supervisorctl status | grep lokole | grep RUNNING | wc -l)
    echo "   ✅ $SERVICES Lokole services running"
else
    echo "   ❌ No Lokole services found or not running"
    sudo supervisorctl status | grep lokole || true
    exit 1
fi

# Check HTTP endpoint
echo "2. Checking HTTP endpoint..."
if curl -f -s http://localhost/lokole/ > /dev/null 2>&1; then
    echo "   ✅ HTTP endpoint accessible"
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/lokole/ || echo "000")
    echo "   ❌ HTTP endpoint failed (code: $HTTP_CODE)"
    exit 1
fi

# Check socket permissions (PR #4259 validation)
echo "3. Checking socket permissions..."
if groups www-data 2>/dev/null | grep -q lokole || groups apache 2>/dev/null | grep -q lokole; then
    echo "   ✅ Web server user in lokole group"
else
    echo "   ❌ Web server user not in lokole group"
    exit 1
fi

# Check Python version
echo "4. Checking Lokole Python environment..."
if [ -f /library/lokole/venv/bin/python ]; then
    PYTHON_VER=$(sudo -u lokole /library/lokole/venv/bin/python --version)
    echo "   ✅ Lokole Python: $PYTHON_VER"
else
    echo "   ⚠️  Lokole venv not found at expected path"
fi

echo ""
echo "🎉 All verification checks passed!"
