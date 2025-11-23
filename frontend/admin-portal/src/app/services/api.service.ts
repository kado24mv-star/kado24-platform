import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.adminBackendUrl;
  
  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('accessToken');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': token ? `Bearer ${token}` : ''
    });
  }

  private buildUrl(endpoint: string): string {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return `${this.baseUrl}${endpoint}`;
  }

  get<T>(endpoint: string, options?: { params?: any }): Observable<T> {
    return this.http.get<T>(this.buildUrl(endpoint), {
      headers: this.getHeaders(),
      params: options?.params
    });
  }

  post<T>(endpoint: string, data: any): Observable<T> {
    return this.http.post<T>(this.buildUrl(endpoint), data, {
      headers: this.getHeaders()
    });
  }

  put<T>(endpoint: string, data: any): Observable<T> {
    return this.http.put<T>(this.buildUrl(endpoint), data, {
      headers: this.getHeaders()
    });
  }

  delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<T>(this.buildUrl(endpoint), {
      headers: this.getHeaders()
    });
  }
}















