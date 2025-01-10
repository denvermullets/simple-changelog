FROM ruby:3.2

# Set working directory
WORKDIR /usr/src/app

# Copy the Ruby script into the container
COPY simple_changelog.rb /usr/src/app/
RUN chmod +x simple_changelog.rb

# Set entry point
ENTRYPOINT ["./simple_changelog.rb"]
