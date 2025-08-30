import React, { useState, useEffect } from 'react';
import { managementAPI } from '../../services/api';
import { useToast } from '../../contexts/ToastContext';
import { Users, GraduationCap, UserCheck, FileText, Clock, TrendingUp } from 'lucide-react';

interface DashboardStats {
  totalStudents: number;
  totalProfessors: number;
  totalAlumni: number;
  pendingAlumni: number;
  totalAssessments: number;
}

const DashboardStatsComponent: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  const { showToast } = useToast();

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      console.log('Fetching dashboard stats...');
      const response = await managementAPI.getDashboardStats();
      console.log('Dashboard stats response:', response);
      
      // Set stats with proper defaults
      setStats({
        totalStudents: response.totalStudents || 0,
        totalProfessors: response.totalProfessors || 0,
        totalAlumni: response.totalAlumni || 0,
        pendingAlumni: response.pendingAlumni || 0,
        totalAssessments: response.totalAssessments || 0
      });
    } catch (error: any) {
      console.error('Failed to fetch dashboard stats:', error);
      // Set default stats if API fails
      setStats({
        totalStudents: 0,
        totalProfessors: 0,
        totalAlumni: 0,
        pendingAlumni: 0,
        totalAssessments: 0
      });
      showToast('Failed to load some dashboard statistics', 'warning');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-purple-600"></div>
      </div>
    );
  }

  if (!stats) {
    return (
      <div className="bg-white rounded-xl shadow-sm border p-8 text-center">
        <div className="text-gray-500">Failed to load dashboard statistics</div>
      </div>
    );
  }

  const statCards = [
    {
      title: 'Total Students',
      value: stats.totalStudents,
      icon: Users,
      color: 'bg-blue-500',
      bgColor: 'bg-blue-50',
      textColor: 'text-blue-600'
    },
    {
      title: 'Total Professors',
      value: stats.totalProfessors,
      icon: GraduationCap,
      color: 'bg-green-500',
      bgColor: 'bg-green-50',
      textColor: 'text-green-600'
    },
    {
      title: 'Verified Alumni',
      value: stats.totalAlumni,
      icon: UserCheck,
      color: 'bg-purple-500',
      bgColor: 'bg-purple-50',
      textColor: 'text-purple-600'
    },
    {
      title: 'Pending Alumni',
      value: stats.pendingAlumni,
      icon: Clock,
      color: 'bg-yellow-500',
      bgColor: 'bg-yellow-50',
      textColor: 'text-yellow-600'
    },
    {
      title: 'Total Assessments',
      value: stats.totalAssessments,
      icon: FileText,
      color: 'bg-indigo-500',
      bgColor: 'bg-indigo-50',
      textColor: 'text-indigo-600'
    },
    {
      title: 'System Health',
      value: '99.9%',
      icon: TrendingUp,
      color: 'bg-emerald-500',
      bgColor: 'bg-emerald-50',
      textColor: 'text-emerald-600'
    }
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <TrendingUp className="h-6 w-6 text-purple-600" />
        <h2 className="text-xl font-semibold">System Overview</h2>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {statCards.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white rounded-xl shadow-sm border p-6 hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600 mb-1">{stat.title}</p>
                  <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
                </div>
                <div className={`p-3 rounded-full ${stat.bgColor}`}>
                  <Icon className={`h-6 w-6 ${stat.textColor}`} />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <h3 className="text-lg font-semibold mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <button className="p-4 text-left border border-gray-200 rounded-lg hover:border-blue-300 hover:bg-blue-50 transition-colors">
            <Users className="h-8 w-8 text-blue-600 mb-2" />
            <div className="font-medium">View All Students</div>
            <div className="text-sm text-gray-600">Manage student accounts</div>
          </button>
          
          <button className="p-4 text-left border border-gray-200 rounded-lg hover:border-green-300 hover:bg-green-50 transition-colors">
            <GraduationCap className="h-8 w-8 text-green-600 mb-2" />
            <div className="font-medium">Professor Management</div>
            <div className="text-sm text-gray-600">Oversee professor activities</div>
          </button>
          
          <button className="p-4 text-left border border-gray-200 rounded-lg hover:border-yellow-300 hover:bg-yellow-50 transition-colors">
            <Clock className="h-8 w-8 text-yellow-600 mb-2" />
            <div className="font-medium">Alumni Verification</div>
            <div className="text-sm text-gray-600">{stats.pendingAlumni} pending approvals</div>
          </button>
          
          <button className="p-4 text-left border border-gray-200 rounded-lg hover:border-purple-300 hover:bg-purple-50 transition-colors">
            <FileText className="h-8 w-8 text-purple-600 mb-2" />
            <div className="font-medium">Assessment Reports</div>
            <div className="text-sm text-gray-600">View system-wide analytics</div>
          </button>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <h3 className="text-lg font-semibold mb-4">System Activity</h3>
        <div className="space-y-3">
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            <div className="flex-1">
              <div className="text-sm font-medium">New student registration</div>
              <div className="text-xs text-gray-600">2 minutes ago</div>
            </div>
          </div>
          
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
            <div className="flex-1">
              <div className="text-sm font-medium">Assessment completed</div>
              <div className="text-xs text-gray-600">5 minutes ago</div>
            </div>
          </div>
          
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
            <div className="flex-1">
              <div className="text-sm font-medium">Alumni verification request</div>
              <div className="text-xs text-gray-600">10 minutes ago</div>
            </div>
          </div>
          
          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
            <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
            <div className="flex-1">
              <div className="text-sm font-medium">New assessment created</div>
              <div className="text-xs text-gray-600">15 minutes ago</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardStatsComponent;