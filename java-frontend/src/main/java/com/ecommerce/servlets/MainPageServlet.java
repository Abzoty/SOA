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

@WebServlet("/main")
public class MainPageServlet extends HttpServlet {

    private static final String INVENTORY_SERVICE = "http://localhost:5002/api/inventory/products";
    private static final String CUSTOMER_SERVICE = "http://localhost:5004/api/customers";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpClient client = HttpClient.newHttpClient();

        try {
            HttpRequest invReq = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE))
                    .GET()
                    .build();

            HttpResponse<String> invRes = client.send(invReq, HttpResponse.BodyHandlers.ofString());

            if (invRes.statusCode() == 200) {
                request.setAttribute("productsJson", invRes.body());
            } else {
                request.setAttribute("error", "Failed to fetch products");
            }

            HttpRequest custReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE + "/list"))
                    .GET()
                    .build();

            HttpResponse<String> custRes = client.send(custReq, HttpResponse.BodyHandlers.ofString());

            if (custRes.statusCode() == 200) {
                request.setAttribute("customersJson", custRes.body());
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        }

        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}
