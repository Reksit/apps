import { Briefcase, Calendar, GraduationCap, Lock, MessageCircle, MessageSquare, Plus, User, Users } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { alumniAPI } from '../../services/api';
import Layout from '../common/Layout';
import AlumniDirectoryNew from '../features/AlumniDirectoryNew';
import AlumniEventRequest from '../features/AlumniEventRequest';
import AlumniManagementRequests from '../features/AlumniManagementRequests';
import AlumniProfileNew from '../features/AlumniProfileNew';
import EventsView from '../features/EventsView';
import JobBoardEnhanced from '../features/JobBoardEnhanced';
import PasswordChange from '../features/PasswordChange';
import UserChat from '../features/UserChat';

interface AlumniStats {
  networkConnections: number;
  studentsHelped: number;
  jobsPosted: number;
}

const AlumniDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState('profile');
  const [stats, setStats] = useState<AlumniStats>({
    networkConnections: 0,
    studentsHelped: 0,
    jobsPosted: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const response = await alumniAPI.getAlumniStats();
      setStats(response);
    } catch (error: any) {
      console.error('Failed to load alumni stats:', error);
      // Don't show error toast, just use default values
    } finally {
      setLoading(false);
    }
  };

  const tabs = [
    { id: 'profile', name: 'My Profile', icon: User },
    { id: 'directory', name: 'Alumni Directory', icon: Users },
    { id: 'password', name: 'Change Password', icon: Lock },
    { id: 'jobs', name: 'Job Board', icon: Briefcase },
    { id: 'events', name: 'Events', icon: Calendar },
    { id: 'request-event', name: 'Request Event', icon: Plus },
    { id: 'management-requests', name: 'Management Requests', icon: MessageSquare },
    { id: 'chat', name: 'Messages', icon: MessageCircle },
  ];

  const renderActiveComponent = () => {
    switch (activeTab) {
      case 'profile':
        return <AlumniProfileNew />;
      case 'directory':
        return <AlumniDirectoryNew />;
      case 'password':
        return <PasswordChange />;
      case 'jobs':
        return <JobBoardEnhanced />;
      case 'events':
        return <EventsView />;
      case 'request-event':
        return <AlumniEventRequest />;
      case 'management-requests':
        return <AlumniManagementRequests />;
      case 'chat':
        return <UserChat />;
      default:
        return <AlumniProfileNew />;
    }
  };

  return (
    <Layout title="Alumni Dashboard">
      <div className="space-y-6">
        {/* Welcome Section */}
        <div className="bg-gradient-to-r from-orange-600 to-red-700 rounded-2xl p-6 text-white">
          <div className="flex items-center space-x-3 mb-2">
            <GraduationCap className="h-8 w-8" />
            <h2 className="text-2xl font-bold">Welcome back, Alumni!</h2>
          </div>
          <p className="text-orange-100">
            Connect with current students and fellow alumni. Share your experience, find opportunities, and give back to the community.
          </p>
        </div>

        {/* Navigation Tabs */}
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8 overflow-x-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm flex items-center space-x-2 transition-colors ${
                    activeTab === tab.id
                      ? 'border-orange-500 text-orange-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <Icon className="h-5 w-5" />
                  <span>{tab.name}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* Quick Stats */}
        {activeTab === 'profile' && (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <div className="bg-white rounded-xl shadow-sm border p-6 text-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-3">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <h3 className="font-semibold mb-1">Network</h3>
              <p className="text-2xl font-bold text-blue-600">
                {loading ? '...' : stats.networkConnections}
              </p>
              <p className="text-sm text-gray-600">Connections</p>
            </div>
            
            <div className="bg-white rounded-xl shadow-sm border p-6 text-center">
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
                <MessageCircle className="h-6 w-6 text-green-600" />
              </div>
              <h3 className="font-semibold mb-1">Mentoring</h3>
              <p className="text-2xl font-bold text-green-600">
                {loading ? '...' : stats.studentsHelped}
              </p>
              <p className="text-sm text-gray-600">Students Helped</p>
            </div>
            
            <div className="bg-white rounded-xl shadow-sm border p-6 text-center">
              <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-3">
                <Briefcase className="h-6 w-6 text-purple-600" />
              </div>
              <h3 className="font-semibold mb-1">Opportunities</h3>
              <p className="text-2xl font-bold text-purple-600">
                {loading ? '...' : stats.jobsPosted}
              </p>
              <p className="text-sm text-gray-600">Jobs Posted</p>
            </div>
          </div>
        )}

        {/* Active Component */}
        <div className="mt-6">
          {renderActiveComponent()}
        </div>
      </div>
    </Layout>
  );
};

export default AlumniDashboard;