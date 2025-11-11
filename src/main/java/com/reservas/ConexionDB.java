package com.reservas;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {

    // ✅ Conexión EXTERNA a Render con SSL habilitado
    private static final String URL = "jdbc:postgresql://dpg-d49r5ji4d50c739kiidg-a.oregon-postgres.render.com:5432/reservas_13r1?sslmode=require";
    private static final String USER = "admin";
    private static final String PASSWORD = "VtIVAVSd98VQWHsczyGmZtl4WPsUzuyd";

    public static Connection getConnection() throws SQLException {
        try {
            // Cargar el driver JDBC de PostgreSQL
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("❌ Error: No se encontró el Driver de PostgreSQL JDBC.", e);
        }

        // Intentar la conexión
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("✅ Conexión exitosa a Render PostgreSQL (externa con SSL)");
            return conn;
        } catch (SQLException e) {
            throw new SQLException("❌ Error al conectar con la base de datos en Render: " + e.getMessage(), e);
        }
    }
}
