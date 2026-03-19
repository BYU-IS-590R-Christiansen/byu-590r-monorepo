import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthStore } from '../stores/auth.store';

export const authGuard = () => {
  const authStore = inject(AuthStore);
  const router = inject(Router);

  console.log('authGuard', authStore.isAuthenticated());
  if (authStore.isAuthenticated()) {
    return true;
  }

  return router.createUrlTree(['/books']);
};
