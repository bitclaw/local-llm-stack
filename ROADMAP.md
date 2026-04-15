# Local LLM Stack - Roadmap

## Current Status

- [x] Basic installation scripts working
- [x] llama.cpp builds with CUDA support
- [x] Qwen models downloadable
- [x] Server runs (CPU mode for 8GB VRAM)
- [x] Daemon mode for background operation
- [x] README with basic troubleshooting

## Known Issues

### Hardware Limitations
- **RTX 5050 8GB VRAM**: Cannot use GPU layers, runs in CPU mode only
- **Solution**: Use 7B model with GPU_LAYERS=0 in config.env

### Script Issues Encountered (Fixed)
- Install scripts checked for `omarchy` command (should use `omarchy-*` pattern)
- No "Omarchy Store" exists - packages install via pacman
- CUDA at `/opt/cuda/bin` not in PATH - scripts now add it
- `--flash-attn` flag format changed in new llama.cpp
- `--log-format` removed in newer versions
- Server stopped when terminal closed - added daemon mode
- Connection "refused" errors - server not running in background

## Planned Features

### High Priority

#### 1. Systemd Service for Auto-Start
```ini
# /etc/systemd/system/local-llm.service
[Unit]
Description=Local LLM Stack Server
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/path/to/local-llm-stack
ExecStart=/path/to/local-llm-stack/scripts/start.sh llama-cpp -d
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

#### 2. Port Conflict Detection
- Check if port 8000 is available before starting
- Suggest alternative port if busy
- Allow configuring custom PORT in config.env

#### 3. Model Validation at Startup
- Verify model file exists before starting server
- Check file size (>1MB to avoid incomplete downloads)
- Warn if VRAM too low for configured GPU_LAYERS

#### 4. Stop Script
```bash
#!/bin/bash
# scripts/stop.sh
pkill -f llama-server && echo "Server stopped" || echo "Server not running"
```

#### 5. Health Check Script
```bash
#!/bin/bash
# scripts/healthcheck.sh
curl -sf http://localhost:8000/health && echo "OK" || echo "Failed"
```

### Medium Priority

#### 6. VRAM Auto-Detection
- Detect available VRAM at startup using nvidia-smi
- Auto-select GPU_LAYERS based on available memory
- Fall back to CPU mode if insufficient VRAM

#### 7. Startup Validation
- Check CUDA in PATH before starting
- Validate model file exists
- Check port availability

#### 8. Configuration Wizard
- Interactive script to set up based on hardware
- Auto-detect GPU, VRAM, RAM
- Recommend model and settings

#### 9. Additional Model Support
- DeepSeek Coder - Alternative coding model
- Codestral - Mistral's code model
- Qwen2.5-VL - Vision model support

#### 10. Docker Support
```yaml
# docker-compose.yml
services:
  llama-cpp:
    image: ghcr.io/ggerganov/llama.cpp:latest
    ports:
      - "8000:8000"
    volumes:
      - ./models:/models
    environment:
      - MODEL=/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf
```

### Lower Priority

#### 11. WebUI Improvements
- Built-in model switcher
- Performance metrics display
- Settings management UI

#### 12. Monitoring Dashboard
- GPU usage via nvidia-smi
- Memory consumption
- Token generation speed

#### 13. Multiple Model Support
- Run different models on different ports
- Model hot-swapping without restart

#### 14. API Key Management
- Configurable API keys
- Rate limiting per key

## Contributing

1. Test on different hardware configurations
2. Report issues at https://github.com/bitclaw/local-llm-stack/issues
3. Submit PRs for fixes and features

## Version History

See [CHANGELOG.md](CHANGELOG.md) for details.