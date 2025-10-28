package ar.edu.ubp.das.dto;

public class SucursalDto {
    private String nroRestaurante;
    private String nroSucursal;
    private String nomSucursal;
    private String calle;
    private Integer nroCalle;
    private String barrio;
    private String codPostal;
    private String telefonos;
    private Integer totalComensales;
    private Integer minTolerenciaReserva;
    private String categoriaPrecio;
    private String nomLocalidad;
    private String nomProvincia;

    public String getNroRestaurante() {
        return nroRestaurante;
    }

    public void setNroRestaurante(String nroRestaurante) {
        this.nroRestaurante = nroRestaurante;
    }

    public String getNroSucursal() {
        return nroSucursal;
    }

    public void setNroSucursal(String nroSucursal) {
        this.nroSucursal = nroSucursal;
    }

    public String getNomSucursal() {
        return nomSucursal;
    }

    public void setNomSucursal(String nomSucursal) {
        this.nomSucursal = nomSucursal;
    }

    public String getCalle() {
        return calle;
    }

    public void setCalle(String calle) {
        this.calle = calle;
    }

    public Integer getNroCalle() {
        return nroCalle;
    }

    public void setNroCalle(Integer nroCalle) {
        this.nroCalle = nroCalle;
    }

    public String getBarrio() {
        return barrio;
    }

    public void setBarrio(String barrio) {
        this.barrio = barrio;
    }

    public String getCodPostal() {
        return codPostal;
    }

    public void setCodPostal(String codPostal) {
        this.codPostal = codPostal;
    }

    public String getTelefonos() {
        return telefonos;
    }

    public void setTelefonos(String telefonos) {
        this.telefonos = telefonos;
    }

    public Integer getTotalComensales() {
        return totalComensales;
    }

    public void setTotalComensales(Integer totalComensales) {
        this.totalComensales = totalComensales;
    }

    public Integer getMinTolerenciaReserva() {
        return minTolerenciaReserva;
    }

    public void setMinTolerenciaReserva(Integer minTolerenciaReserva) {
        this.minTolerenciaReserva = minTolerenciaReserva;
    }

    public String getCategoriaPrecio() {
        return categoriaPrecio;
    }

    public void setCategoriaPrecio(String categoriaPrecio) {
        this.categoriaPrecio = categoriaPrecio;
    }

    public String getNomLocalidad() {
        return nomLocalidad;
    }

    public void setNomLocalidad(String nomLocalidad) {
        this.nomLocalidad = nomLocalidad;
    }

    public String getNomProvincia() {
        return nomProvincia;
    }

    public void setNomProvincia(String nomProvincia) {
        this.nomProvincia = nomProvincia;
    }
}

