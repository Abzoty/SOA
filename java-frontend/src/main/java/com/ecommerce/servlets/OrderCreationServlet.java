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

@WebServlet("/createOrderFinal")
public class OrderCreationServlet extends HttpServlet {

    private static final String ORDER_SERVICE = "http://localhost:5001/api/orders/create";
    private static final String CUSTOMER_SERVICE = "http://localhost:5004/api/customers";
    private static final String INVENTORY_SERVICE = "http://localhost:5002/api/inventory/update";
    private static final String NOTIFICATION_SERVICE = "http://localhost:5005/api/notifications/send";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        String pricingDataStr = request.getParameter("pricing_data");

        if (customerId == null || pricingDataStr == null) {
            request.setAttribute("error", "Missing required data");
            request.getRequestDispatcher("confirmation.jsp").forward(request, response);
            return;
        }

        HttpClient client = HttpClient.newHttpClient();

        try {
            JSONObject pricingData = new JSONObject(pricingDataStr);
            JSONArray items = pricingData.getJSONArray("items");

            JSONArray productsForOrder = new JSONArray();
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                JSONObject product = new JSONObject();
                product.put("product_id", item.getInt("product_id"));
                product.put("quantity", item.getInt("quantity"));
                productsForOrder.put(product);
            }

            JSONObject orderPayload = new JSONObject();
            orderPayload.put("customer_id", Integer.parseInt(customerId));
            orderPayload.put("products", productsForOrder);
            orderPayload.put("subtotal", pricingData.getDouble("subtotal"));
            orderPayload.put("tax_rate", pricingData.getDouble("tax_rate"));
            orderPayload.put("tax_amount", pricingData.getDouble("tax_amount"));
            orderPayload.put("total_amount", pricingData.getDouble("total"));

            HttpRequest orderReq = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(orderPayload.toString()))
                    .build();

            HttpResponse<String> orderRes = client.send(orderReq, HttpResponse.BodyHandlers.ofString());

            if (orderRes.statusCode() == 201) {
                JSONObject orderResponse = new JSONObject(orderRes.body());
                JSONObject order = orderResponse.getJSONObject("order");
                int orderId = order.getInt("order_id");

                JSONObject productsPayload = new JSONObject();
                productsPayload.put("products", productsForOrder);

                HttpRequest invReq = HttpRequest.newBuilder()
                        .uri(URI.create(INVENTORY_SERVICE))
                        .header("Content-Type", "application/json")
                        .PUT(HttpRequest.BodyPublishers.ofString(productsPayload.toString()))
                        .build();

                client.send(invReq, HttpResponse.BodyHandlers.ofString());

                int pointsToAdd = (int) (pricingData.getDouble("total") / 5);

                JSONObject loyaltyPayload = new JSONObject();
                loyaltyPayload.put("points_change", pointsToAdd);

                HttpRequest loyaltyReq = HttpRequest.newBuilder()
                        .uri(URI.create(CUSTOMER_SERVICE + "/" + customerId + "/loyalty"))
                        .header("Content-Type", "application/json")
                        .PUT(HttpRequest.BodyPublishers.ofString(loyaltyPayload.toString()))
                        .build();

                client.send(loyaltyReq, HttpResponse.BodyHandlers.ofString());

                HttpRequest custReq = HttpRequest.newBuilder()
                        .uri(URI.create(CUSTOMER_SERVICE + "/" + customerId))
                        .GET()
                        .build();

                HttpResponse<String> custRes = client.send(custReq, HttpResponse.BodyHandlers.ofString());
                JSONObject customer = new JSONObject(custRes.body());

                JSONObject notifPayload = new JSONObject();
                notifPayload.put("order_id", orderId);
                notifPayload.put("customer_id", Integer.parseInt(customerId));
                notifPayload.put("customer_name", customer.getString("name"));
                notifPayload.put("customer_email", customer.getString("email"));

                HttpRequest notifReq = HttpRequest.newBuilder()
                        .uri(URI.create(NOTIFICATION_SERVICE))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(notifPayload.toString()))
                        .build();

                client.send(notifReq, HttpResponse.BodyHandlers.ofString());

                request.setAttribute("success", true);
                request.setAttribute("orderData", orderResponse.toString());
                request.setAttribute("pointsAdded", pointsToAdd);
            } else {
                request.setAttribute("success", false);
                request.setAttribute("error", "Order creation failed: " + orderRes.body());
            }

        } catch (Exception e) {
            request.setAttribute("success", false);
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        request.getRequestDispatcher("confirmation.jsp").forward(request, response);
    }
}
