package com.ecommerce.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@WebServlet("/products")
public class ListProductsServlet extends HttpServlet {

    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory/list";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpClient client = HttpClient.newHttpClient();

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE_URL))
                    .GET()
                    .build();

            HttpResponse<String> res = client.send(req,
                    HttpResponse.BodyHandlers.ofString());

            if (res.statusCode() == 200) {
                request.setAttribute("productsJson", res.body());
                request.setAttribute("success", true);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Failed to fetch products. Status: " + res.statusCode());
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", "Error connecting to Inventory Service: " + e.getMessage());
        }

        request.getRequestDispatcher("products.jsp").forward(request, response);
    }
}