# 1. Tahap Build
FROM rust:slim-bookworm as builder
WORKDIR /app

# Install dependencies sistem yang dibutuhkan untuk build ALSA
RUN apt-get update && apt-get install -y pkg-config libasound2-dev

# Copy semua file dari repo
COPY . .

# Build project Rust
RUN cargo build --release

# 2. Tahap Production (Image yang lebih ringan)
FROM debian:bookworm-slim
WORKDIR /app

# Install ALSA library untuk runtime
RUN apt-get update && apt-get install -y libasound2 && rm -rf /var/lib/apt/lists/*

# Copy binary dari tahap build sebelumnya
COPY --from=builder /app/target/release/fcm_recv ./fcm_recv
COPY --from=builder /app/target/release/test_notification ./test_notification

# Jalankan file binary utama (asumsi fcm_recv adalah worker utamanya)
CMD ["./fcm_recv"]
