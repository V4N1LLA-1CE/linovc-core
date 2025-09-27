# Use the official Elixir image
FROM elixir:1.18.4-otp-28

# Install build dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs \
  npm \
  inotify-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy config files
COPY config ./config

# Copy the entire application
COPY . .

# Compile the application
RUN mix compile

# Expose port 4000
EXPOSE 4000

# Default command for development
CMD ["mix", "phx.server"]
