import { inject, Injectable } from '@angular/core';
import { Book } from './books.service';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { AuthService } from './auth.service';
import { environment } from '../../../environments/environment';

export interface Drink {
  id: number;
  name: string;
  is_diet: boolean;
  size: string;
  image: string;
}

@Injectable({
  providedIn: 'root',
})
export class DrinksService {
  private http = inject(HttpClient);
  private authService = inject(AuthService);
  private apiUrl = environment.apiUrl;

  private getAuthHeaders(): { [key: string]: string } {
    const user = this.authService.getStoredUser();
    if (user && user.token) {
      return { Authorization: `Bearer ${user.token}` };
    }
    return {};
  }

  getDrinks(): Observable<{
    success: boolean;
    results: Drink[];
    message: string;
  }> {
    return this.http.get<{
      success: boolean;
      results: Drink[];
      message: string;
    }>(`${this.apiUrl}drinks`, { headers: this.getAuthHeaders() });
  }
}
