package com.reservas;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EspacioDAO {

    private static final Logger LOGGER = Logger.getLogger(EspacioDAO.class.getName());

    // Contar total de recursos (espacios)
    public int contarEspacios() {
        int total = 0;
        String sql = "SELECT COUNT(*) AS total FROM recursos"; // Tu tabla se llama 'recursos'

        try (Connection con = ConexionDB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error al contar recursos", e);
        }

        return total;
    }
}
