#include <print>
#include <asio.hpp>
#include <rfl.hpp>
#include "rfl/json.hpp"

struct Message {
    std::string mode;
};

void read_message(asio::local::stream_protocol::acceptor &acceptor) {
    asio::streambuf buffer;
    asio::error_code error;

    while (true) {
        auto connection = acceptor.accept();
        buffer.consume(buffer.size());

        (void) asio::read_until(connection, buffer, "\n", error);

        if (error) {
            if (error == asio::error::eof) {
                std::println("Connection closed");
            } else {
                std::println("Error on receive: {}", error.message());
                break;
            }
        }
        std::istream is(&buffer);
        std::string message;
        std::getline(is, message);

        std::string response = rfl::json::write(Message{.mode = message});

        auto len = static_cast<std::uint32_t>(response.size());
        std::cout.write(reinterpret_cast<const char *>(&len), sizeof(std::uint32_t));
        std::cout << response;
        std::cout << std::flush;
    }
}

int main() {
    auto runtime_dir = std::getenv("XDG_RUNTIME_DIR");
    if (!runtime_dir) {
        std::println("XDG_RUNTIME_DIR is not set");
        return -1;
    }
    auto socket_path = std::format("{}/color_control.socket", runtime_dir);
    unlink(socket_path.c_str());

    try {
        asio::io_context io_context;

        asio::local::stream_protocol::socket socket(io_context);
        asio::local::stream_protocol::acceptor acceptor(io_context, socket_path);

        read_message(acceptor);
    } catch (std::exception &e) {
        std::println("Exception: {}", e.what());
    }

    return 0;
}
