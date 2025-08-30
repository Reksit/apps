import React, { createContext, useContext, useEffect, useState } from 'react';
import { authAPI } from '../services/api';

interface User {
  id: string;
  email: string;
  name: string;
  role: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem('token');
    const storedUser = localStorage.getItem('user');

    if (storedToken && storedUser) {
      // Check if token is expired
      try {
        const payload = JSON.parse(atob(storedToken.split('.')[1]));
        const currentTime = Date.now() / 1000;
        
        if (payload.exp && payload.exp < currentTime) {
          // Token is expired, clear storage
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          console.log('Token expired, cleared from storage');
        } else {
          setToken(storedToken);
          setUser(JSON.parse(storedUser));
        }
      } catch (error) {
        // Invalid token format, clear storage
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        console.log('Invalid token format, cleared from storage');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    try {
      const response = await authAPI.login({ email, password });
      const userData = {
        id: response.id,
        email: response.email,
        name: response.name,
        role: response.role,
      };

      setUser(userData);
      setToken(response.accessToken);
      
      localStorage.setItem('token', response.accessToken);
      localStorage.setItem('user', JSON.stringify(userData));
    } catch (error: any) {
      throw new Error(error.response?.data || 'Login failed');
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  };

  const value = {
    user,
    token,
    login,
    logout,
    loading,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};