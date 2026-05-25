import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login').then(m => m.Login)
  },
  {
    path: 'forgot-password',
    loadComponent: () => import('./pages/forgot-password/forgot-password').then(m => m.ForgotPassword)
  },
  {
    path: 'otp-verification',
    loadComponent: () => import('./pages/otp-verification/otp-verification').then(m => m.OtpVerification)
  },
  {
    path: 'new-password',
    loadComponent: () => import('./pages/new-password/new-password').then(m => m.NewPassword)
  },
  {
    path: '',
    loadComponent: () => import('./layouts/main-layout/main-layout').then(m => m.MainLayout),
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./pages/dashboard/dashboard').then(m => m.Dashboard)
      },
      {
        path: 'school-buses',
        loadComponent: () => import('./pages/school-buses/school-buses').then(m => m.SchoolBuses)
      },
      {
        path: 'school-buses/new',
        loadComponent: () => import('./pages/bus-create/bus-create').then(m => m.BusCreatePage)
      },
      {
        path: 'school-buses/:id/edit',
        loadComponent: () => import('./pages/bus-edit/bus-edit').then(m => m.BusEditPage)
      },
      {
        path: 'students',
        loadComponent: () => import('./pages/students/students').then(m => m.Students)
      },
      {
        path: 'students/new',
        loadComponent: () => import('./pages/student-create/student-create').then(m => m.StudentCreatePage)
      },
      {
        path: 'students/:id',
        loadComponent: () => import('./pages/student-details/student-details').then(m => m.StudentDetailsPage)
      },
      {
        path: 'students/:id/edit',
        loadComponent: () => import('./pages/student-edit/student-edit').then(m => m.StudentEditPage)
      },
      {
        path: 'trip-attendance',
        loadComponent: () => import('./pages/trip-attendance/trip-attendance').then(m => m.TripAttendance)
      },
      {
        path: 'routes',
        loadComponent: () => import('./pages/routes-stops/routes-stops').then(m => m.RoutesStops)
      },
      {
        path: 'drivers',
        loadComponent: () => import('./pages/bus-conductors/bus-conductors').then(m => m.BusConductors)
      },
      {
        path: 'drivers/new',
        loadComponent: () => import('./pages/conductor-create/conductor-create').then(m => m.ConductorCreatePage)
      },
      {
        path: 'drivers/:id',
        loadComponent: () => import('./pages/conductor-details/conductor-details').then(m => m.ConductorDetailsPage)
      },
      {
        path: 'drivers/:id/edit',
        loadComponent: () => import('./pages/conductor-edit/conductor-edit').then(m => m.ConductorEditPage)
      },
      {
        path: 'requests',
        loadComponent: () => import('./pages/user-requests').then(m => m.UserRequests)
      },
      {
        path: 'requests/:id',
        loadComponent: () => import('./pages/request-details/request-details').then(m => m.RequestDetailsPage)
      },
      {
        path: 'absences',
        loadComponent: () => import('./pages/absences/absences').then(m => m.AbsencesPage)
      },
      {
        path: 'incidents',
        loadComponent: () => import('./pages/incidents/incidents').then(m => m.Incidents)
      }
      ,
      {
        path: 'profile',
        loadComponent: () => import('./pages/profile/profile').then(m => m.ProfilePage)
      }
    ]
  }
];
