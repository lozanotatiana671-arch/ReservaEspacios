package com.reservas;

public class Recurso {

    // 🔹 Campos principales
    private int id;
    private String nombre;
    private String descripcion;
    private String tipo;
    private String estado;
    private String mensajeBloqueo; 
    private double tarifa;
    private String imagen;

    // 🔹 Campos adicionales usados en el JSP
    private boolean disponible;
    private String ubicacion;
    private int capacidad;
    private double promedioValoracion;
    private int totalResenas;

    // 🔹 (Nuevo opcional) Campos extendidos para integración futura
    private int totalTestimonios;       // Total general de testimonios asociados
    private double promedioGeneral;     // Promedio general para reportes o dashboards

    // ===============================
    // 🔸 Getters y Setters
    // ===============================

    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public String getNombre() { 
        return nombre; 
    }
    public void setNombre(String nombre) { 
        this.nombre = nombre; 
    }

    public String getDescripcion() { 
        return descripcion; 
    }
    public void setDescripcion(String descripcion) { 
        this.descripcion = descripcion; 
    }

    public String getTipo() { 
        return tipo; 
    }
    public void setTipo(String tipo) { 
        this.tipo = tipo; 
    }

    public String getEstado() { 
        return estado; 
    }
    public void setEstado(String estado) { 
        this.estado = estado; 
    }

    public String getMensajeBloqueo() { 
        return mensajeBloqueo; 
    }
    public void setMensajeBloqueo(String mensajeBloqueo) { 
        this.mensajeBloqueo = mensajeBloqueo; 
    }

    public double getTarifa() { 
        return tarifa; 
    }
    public void setTarifa(double tarifa) { 
        this.tarifa = tarifa; 
    }

    public String getImagen() { 
        return imagen; 
    }
    public void setImagen(String imagen) { 
        this.imagen = imagen; 
    }

    // ===============================
    // 🔸 Nuevos campos para JSP
    // ===============================

    public boolean isDisponible() { 
        return disponible; 
    }
    public void setDisponible(boolean disponible) { 
        this.disponible = disponible; 
    }

    public String getUbicacion() { 
        return ubicacion; 
    }
    public void setUbicacion(String ubicacion) { 
        this.ubicacion = ubicacion; 
    }

    public int getCapacidad() { 
        return capacidad; 
    }
    public void setCapacidad(int capacidad) { 
        this.capacidad = capacidad; 
    }

    public double getPromedioValoracion() { 
        return promedioValoracion; 
    }
    public void setPromedioValoracion(double promedioValoracion) { 
        this.promedioValoracion = promedioValoracion; 
    }

    public int getTotalResenas() { 
        return totalResenas; 
    }
    public void setTotalResenas(int totalResenas) { 
        this.totalResenas = totalResenas; 
    }

    // ===============================
    // 🔸 Campos extendidos (no interfieren con nada actual)
    // ===============================

    public int getTotalTestimonios() {
        return totalTestimonios;
    }
    public void setTotalTestimonios(int totalTestimonios) {
        this.totalTestimonios = totalTestimonios;
    }

    public double getPromedioGeneral() {
        return promedioGeneral;
    }
    public void setPromedioGeneral(double promedioGeneral) {
        this.promedioGeneral = promedioGeneral;
    }
}
