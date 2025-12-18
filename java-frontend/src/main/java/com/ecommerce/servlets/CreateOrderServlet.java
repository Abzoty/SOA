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
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/createOrder")
public class CreateOrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL = "http://localhost:5001/api/orders/create";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to order form page
        request.getRequestDispatcher("create-order.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get form parameters
            String customerId = request.getParameter("customer_id");
            String region = request.getParameter("region");
            String[] productIds = request.getParameterValues("product_id[]");
            String[] quantities = request.getParameterValues("quantity[]");

            // Validate inputs
            if (customerId == null || productIds == null || quantities == null) {
                request.setAttribute("error", "Missing required fields");
                request.getRequestDispatcher("create-order.jsp").forward(request, response);
                return;
            }

            // Build JSON payload
            JSONObject orderData = new JSONObject();
            orderData.put("customer_id", Integer.parseInt(customerId));
            orderData.put("region", region != null ? region : "Cairo");

            JSONArray productsArray = new JSONArray();
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] != null && !productIds[i].isEmpty() &&
                        quantities[i] != null && !quantities[i].isEmpty()) {
                    JSONObject product = new JSONObject();
                    product.put("product_id", Integer.parseInt(productIds[i]));
                    product.put("quantity", Integer.parseInt(quantities[i]));
                    productsArray.put(product);
                }
            }
            orderData.put("products", productsArray);

            // Call Order Service
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest orderRequest = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(orderData.toString()))
                    .build();

            HttpResponse<String> orderResponse = client.send(orderRequest,
                    HttpResponse.BodyHandlers.ofString());

            if (orderResponse.statusCode() == 201) {
                JSONObject result = new JSONObject(orderResponse.body());

                request.setAttribute("success", true);
                request.setAttribute("orderData", result.toString());
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Order creation failed: " + orderResponse.body());
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        request.getRequestDispatcher("order-confirmation.jsp").forward(request, response);
    }
}