FROM ruby:3.2

# Set working directory
WORKDIR /usr/src/app

# Copy the Ruby script and dependencies
COPY simple_changelog.rb /usr/src/app/
RUN chmod +x /usr/src/app/simple_changelog.rb

# Set entry point
ENTRYPOINT ["./simple_changelog.rb"]
