package ar.edu.ubp.das.dto.request;

public class GetMenusPorSucursalRequest {
  private String nroRestaurante;
  private String nroSucursal;

  public GetMenusPorSucursalRequest() {}

  public GetMenusPorSucursalRequest(String nroRestaurante, String nroSucursal) {
    this.nroRestaurante = nroRestaurante;
    this.nroSucursal = nroSucursal;
  }

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
}
