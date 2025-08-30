import axios from 'axios';
import { Building, GraduationCap, Mail, MessageCircle, Phone, Search, Users } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { useToast } from '../../contexts/ToastContext';
import { alumniDirectoryAPI } from '../../services/api';

interface AlumniProfile {
  id: string;
  name: string;
  email: string;
  department: string;
  phoneNumber?: string;
  graduationYear?: string;
  batch?: string;
  placedCompany?: string;
}

const AlumniDirectoryNew: React.FC = () => {
  const { user } = useAuth();
  const [alumni, setAlumni] = useState<AlumniProfile[]>([]);
  const [filteredAlumni, setFilteredAlumni] = useState<AlumniProfile[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [selectedYear, setSelectedYear] = useState('');
  const [loading, setLoading] = useState(true);
  const [selectedAlumni, setSelectedAlumni] = useState<AlumniProfile | null>(null);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const { showToast } = useToast();

  useEffect(() => {
    loadAlumniDirectory();
  }, []);

  useEffect(() => {
    filterAlumni();
  }, [searchTerm, selectedDepartment, selectedYear, alumni]);

  const loadAlumniDirectory = async () => {
    try {
      const token = localStorage.getItem('token');
      
      // Try the new alumni directory API first
      let response;
      try {
        // For alumni users, use the specific endpoint that excludes their own profile
        if (user?.role === 'ALUMNI') {
          const alumniData = await alumniDirectoryAPI.getAllVerifiedAlumniForAlumni();
          response = { data: alumniData };
        } else {
          // For other users, use the general endpoint
          const alumniData = await alumniDirectoryAPI.getAllVerifiedAlumni();
          response = { data: alumniData };
        }
      } catch (error) {
        // Fallback to the old API
        response = await axios.get('http://localhost:8080/api/users/alumni', {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        // For alumni users, manually filter out current user from fallback response
        if (user?.role === 'ALUMNI' && Array.isArray(response.data)) {
          response.data = response.data.filter((alum: any) => {
            // Filter by ID if available
            if (user?.id && alum.id === user.id) {
              return false;
            }
            // Filter by email as backup
            if (user?.email && alum.email === user.email) {
              return false;
            }
            return true;
          });
        }
      }
      
      // Transform the response data
      const alumniData = Array.isArray(response.data) ? response.data : [];
      
      // No need to filter again here since backend handles it for alumni users
      const transformedAlumni = alumniData.map((alum: any) => ({
        id: alum.id,
        name: alum.name || 'Anonymous',
        email: alum.email || '',
        department: alum.department || 'Unknown',
        phoneNumber: alum.phoneNumber || '',
        graduationYear: alum.graduationYear || 'Unknown',
        batch: alum.batch || 'Unknown',
        placedCompany: alum.placedCompany || alum.currentCompany || 'Not specified'
      }));
      
      setAlumni(transformedAlumni);
      console.log('Loaded alumni directory:', transformedAlumni.length, 'alumni');
    } catch (error: any) {
      console.error('Error loading alumni directory:', error);
      const errorMessage = error.response?.data?.message || error.response?.data || 'Failed to load alumni directory';
      showToast(errorMessage, 'error');
    } finally {
      setLoading(false);
    }
  };

  const filterAlumni = () => {
    let filtered = [...alumni];

    // Filter by search term
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(alum => 
        alum.name.toLowerCase().includes(term) ||
        alum.email.toLowerCase().includes(term) ||
        alum.department?.toLowerCase().includes(term) ||
        alum.placedCompany?.toLowerCase().includes(term)
      );
    }

    // Filter by department
    if (selectedDepartment) {
      filtered = filtered.filter(alum => alum.department === selectedDepartment);
    }

    // Filter by graduation year
    if (selectedYear) {
      filtered = filtered.filter(alum => alum.graduationYear === selectedYear);
    }

    setFilteredAlumni(filtered);
  };

  const handleViewProfile = (alumni: AlumniProfile) => {
    setSelectedAlumni(alumni);
    setShowDetailModal(true);
  };

  const handleSendMentoringRequest = async (alumniId: string, alumniName: string) => {
    try {
      const token = localStorage.getItem('token');
      const requestData = {
        receiverId: alumniId,
        message: `Hi ${alumniName}, I would like to connect with you for mentoring and career guidance. Thank you!`
      };
      
      await axios.post('http://localhost:8080/api/connections/send-request', requestData, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      showToast('Mentoring request sent successfully!', 'success');
    } catch (error: any) {
      console.error('Error sending mentoring request:', error);
      showToast('Failed to send mentoring request', 'error');
    }
  };

  const getDepartments = () => {
    const departments = new Set(alumni.map(alum => alum.department).filter(Boolean));
    return Array.from(departments).sort();
  };

  const getGraduationYears = () => {
    const years = new Set(alumni.map(alum => alum.graduationYear).filter(Boolean));
    return Array.from(years).sort().reverse();
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Alumni Directory
        </h1>
        <p className="text-gray-600">
          Connect with {alumni.length} verified alumni from our institution
        </p>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Search */}
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Search Alumni
            </label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by name, email, department, or company..."
                className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          {/* Department Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Department
            </label>
            <select
              value={selectedDepartment}
              onChange={(e) => setSelectedDepartment(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Departments</option>
              {getDepartments().map(dept => (
                <option key={dept} value={dept}>{dept}</option>
              ))}
            </select>
          </div>

          {/* Year Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Graduation Year
            </label>
            <select
              value={selectedYear}
              onChange={(e) => setSelectedYear(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Years</option>
              {getGraduationYears().map(year => (
                <option key={year} value={year}>{year}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Results Count */}
        <div className="mt-4 text-sm text-gray-600">
          Showing {filteredAlumni.length} of {alumni.length} alumni
        </div>
      </div>

      {/* Alumni Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredAlumni.length === 0 ? (
          <div className="col-span-full text-center py-12">
            <Users className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No Alumni Found</h3>
            <p className="text-gray-500">Try adjusting your search criteria.</p>
          </div>
        ) : (
          filteredAlumni.map((alum) => (
            <div key={alum.id} className="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900 mb-1">
                    {alum.name}
                  </h3>
                  <p className="text-sm text-gray-600">{alum.department}</p>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleViewProfile(alum)}
                    className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                  >
                    View Profile
                  </button>
                  <button
                    onClick={() => handleSendMentoringRequest(alum.id, alum.name)}
                    className="text-orange-600 hover:text-orange-800 text-sm font-medium flex items-center space-x-1"
                  >
                    <MessageCircle className="h-3 w-3" />
                    <span>Mentoring</span>
                  </button>
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex items-center text-sm text-gray-600">
                  <Mail className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span className="truncate">{alum.email}</span>
                </div>

                {alum.phoneNumber && (
                  <div className="flex items-center text-sm text-gray-600">
                    <Phone className="h-4 w-4 mr-2 flex-shrink-0" />
                    <span>{alum.phoneNumber}</span>
                  </div>
                )}

                {alum.placedCompany && (
                  <div className="flex items-center text-sm text-gray-600">
                    <Building className="h-4 w-4 mr-2 flex-shrink-0" />
                    <span className="truncate">{alum.placedCompany}</span>
                  </div>
                )}

                <div className="flex items-center text-sm text-gray-600">
                  <GraduationCap className="h-4 w-4 mr-2 flex-shrink-0" />
                  <span>Class of {alum.graduationYear || 'N/A'}</span>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-200 flex space-x-2">
                <button
                  onClick={() => handleViewProfile(alum)}
                  className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors text-sm font-medium"
                >
                  View Profile
                </button>
                <button
                  onClick={() => handleSendMentoringRequest(alum.id, alum.name)}
                  className="flex-1 bg-orange-600 text-white py-2 px-4 rounded-md hover:bg-orange-700 transition-colors text-sm font-medium flex items-center justify-center space-x-1"
                >
                  <MessageCircle className="h-4 w-4" />
                  <span>Request Mentoring</span>
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Detail Modal */}
      {showDetailModal && selectedAlumni && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-xl font-semibold text-gray-900">Alumni Profile</h3>
                <button
                  onClick={() => setShowDetailModal(false)}
                  className="text-gray-400 hover:text-gray-500"
                >
                  ✕
                </button>
              </div>

              <div className="space-y-4">
                <div className="text-center">
                  <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-3">
                    <Users className="h-8 w-8 text-blue-600" />
                  </div>
                  <h4 className="text-lg font-semibold text-gray-900">{selectedAlumni.name}</h4>
                  <p className="text-sm text-gray-600">{selectedAlumni.department}</p>
                </div>

                <div className="space-y-3">
                  <div className="flex items-center text-sm">
                    <Mail className="h-4 w-4 mr-3 text-gray-400" />
                    <span className="text-gray-900">{selectedAlumni.email}</span>
                  </div>

                  {selectedAlumni.phoneNumber && (
                    <div className="flex items-center text-sm">
                      <Phone className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-gray-900">{selectedAlumni.phoneNumber}</span>
                    </div>
                  )}

                  {selectedAlumni.placedCompany && (
                    <div className="flex items-center text-sm">
                      <Building className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-gray-900">{selectedAlumni.placedCompany}</span>
                    </div>
                  )}

                  <div className="flex items-center text-sm">
                    <GraduationCap className="h-4 w-4 mr-3 text-gray-400" />
                    <span className="text-gray-900">
                      Graduated in {selectedAlumni.graduationYear || 'Unknown'}
                      {selectedAlumni.batch && ` (Batch: ${selectedAlumni.batch})`}
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex space-x-3 mt-6 pt-4 border-t">
                <button
                  onClick={() => setShowDetailModal(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  Close
                </button>
                <button
                  onClick={() => {
                    window.location.href = `mailto:${selectedAlumni.email}`;
                  }}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700"
                >
                  Send Email
                </button>
                <button
                  onClick={() => handleSendMentoringRequest(selectedAlumni.id, selectedAlumni.name)}
                  className="px-4 py-2 bg-orange-600 text-white rounded-md text-sm font-medium hover:bg-orange-700 flex items-center space-x-2"
                >
                  <MessageCircle className="h-4 w-4" />
                  <span>Request Mentoring</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AlumniDirectoryNew;
