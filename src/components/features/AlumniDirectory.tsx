import { Building, Calendar, Github, Linkedin, MapPin, MessageCircle, Search, User, UserCheck } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { useToast } from '../../contexts/ToastContext';
import { alumniDirectoryAPI, connectionAPI } from '../../services/api';
import UserProfile from './UserProfile';

interface AlumniMember {
  id: string;
  name: string;
  email: string;
  graduationYear: string;
  department: string;
  currentJob: string;
  company: string;
  location: string;
  skills: string[];
  linkedinUrl?: string;
  githubUrl?: string;
  portfolioUrl?: string;
  aboutMe?: string;
  industry?: string;
  workExperience?: number;
  isAvailableForMentorship: boolean;
  profilePicture?: string;
  batch?: string;
}

const AlumniDirectory: React.FC = () => {
  const [alumni, setAlumni] = useState<AlumniMember[]>([]);
  const [filteredAlumni, setFilteredAlumni] = useState<AlumniMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDepartment, setSelectedDepartment] = useState('');
  const [selectedYear, setSelectedYear] = useState('');
  const [selectedProfileId, setSelectedProfileId] = useState<string | null>(null);
  const [showProfile, setShowProfile] = useState(false);

  const { showToast } = useToast();
  const { user } = useAuth();

  useEffect(() => {
    loadAlumni();
  }, []);

  useEffect(() => {
    filterAlumni();
  }, [searchQuery, selectedDepartment, selectedYear, alumni]);

  const loadAlumni = async () => {
    try {
      setLoading(true);
      console.log('Loading alumni directory...');
      // Try multiple API endpoints to ensure we get alumni data
      let response;
      try {
        response = await alumniDirectoryAPI.getAllVerifiedAlumni();
        console.log('Alumni directory API response:', response);
      } catch (error) {
        console.log('New API failed, trying fallback...');
        // Try debug endpoint as fallback
        const token = localStorage.getItem('token');
        const fallbackResponse = await fetch('http://localhost:8080/api/debug/alumni', {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        if (fallbackResponse.ok) {
          const debugData = await fallbackResponse.json();
          response = debugData.alumni || [];
        } else {
          throw new Error('Both API endpoints failed');
        }
      }
      
      // The new API returns alumni data directly
      const alumniData = Array.isArray(response) ? response : [];
      console.log('Alumni data array length:', alumniData.length);
      
      // Transform the data to match our interface and exclude current user
      const transformedAlumni = alumniData
        .filter((member: any) => member.id !== user?.id) // Exclude current user from directory
        .map((member: any) => ({
          id: member.id,
          name: member.name || 'Anonymous',
          email: member.email || '',
          graduationYear: member.graduationYear || 'Unknown',
          department: member.department || 'Unknown',
          currentJob: member.currentJob || member.currentPosition || member.jobTitle || 'Not specified',
          company: member.currentCompany || member.placedCompany || 'Not specified',
          location: member.location || member.workLocation || 'Not specified',
          skills: member.skills || member.technicalSkills || [],
          batch: member.batch || 'Unknown',
          isAvailableForMentorship: member.isAvailableForMentorship || member.mentorshipAvailable || false,
          linkedinUrl: member.linkedinUrl || '',
          githubUrl: member.githubUrl || '',
          portfolioUrl: member.portfolioUrl || '',
          aboutMe: member.aboutMe || '',
          industry: member.industry || 'Not specified',
          workExperience: member.workExperience || 0,
          profilePicture: member.profilePicture || ''
        }));
      
      setAlumni(transformedAlumni);
      setFilteredAlumni(transformedAlumni);
      console.log('Transformed alumni data:', transformedAlumni);
      
      if (transformedAlumni.length === 0) {
        console.log('No alumni found, but not showing toast to avoid spam');
      }
    } catch (error) {
      console.error('Error loading alumni:', error);
      showToast('Failed to load alumni directory. Please try again.', 'error');
      setAlumni([]);
      setFilteredAlumni([]);
    } finally {
      setLoading(false);
    }
  };

  const filterAlumni = () => {
    let filtered = [...alumni];

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(member =>
        member.name.toLowerCase().includes(query) ||
        (member.company && member.company.toLowerCase().includes(query)) ||
        (member.currentJob && member.currentJob.toLowerCase().includes(query)) ||
        (member.email && member.email.toLowerCase().includes(query)) ||
        (member.skills && member.skills.some(skill => skill.toLowerCase().includes(query)))
      );
    }

    // Department filter
    if (selectedDepartment) {
      filtered = filtered.filter(member => member.department === selectedDepartment);
    }

    // Year filter
    if (selectedYear) {
      filtered = filtered.filter(member => member.graduationYear === selectedYear);
    }

    setFilteredAlumni(filtered);
  };

  const handleViewProfile = (userId: string) => {
    setSelectedProfileId(userId);
    setShowProfile(true);
  };

  const handleCloseProfile = () => {
    setShowProfile(false);
    setSelectedProfileId(null);
  };

  const handleRequestMentoring = async (alumniId: string, alumniName: string) => {
    try {
      const message = `Hi ${alumniName}, I would like to request your mentorship. I'm interested in learning from your experience and would appreciate any guidance you can offer.`;
      await connectionAPI.sendConnectionRequest(alumniId, message);
      showToast('Mentoring request sent successfully!', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Failed to send mentoring request', 'error');
    }
  };

  const departments = [...new Set(alumni.map(member => member.department).filter(Boolean))];
  const years = [...new Set(alumni.map(member => member.graduationYear).filter(Boolean))].sort((a, b) => (b || '').localeCompare(a || ''));

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Alumni Directory</h1>
        <p className="text-gray-600">Connect with fellow St. Joseph's alumni worldwide</p>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <input
              type="text"
              placeholder="Search alumni..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
            />
          </div>

          <select
            value={selectedDepartment}
            onChange={(e) => setSelectedDepartment(e.target.value)}
            className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
          >
            <option value="">All Departments</option>
            {departments.map(dept => (
              <option key={dept} value={dept}>{dept}</option>
            ))}
          </select>

          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(e.target.value)}
            className="w-full p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
          >
            <option value="">All Years</option>
            {years.map(year => (
              <option key={year} value={year}>Class of {year}</option>
            ))}
          </select>
        </div>

        <div className="text-sm text-gray-600">
          Showing {filteredAlumni.length} of {alumni.length} alumni
        </div>
      </div>

      {/* Alumni Grid */}
      {filteredAlumni.length === 0 ? (
        <div className="bg-white rounded-xl shadow-sm border p-8 text-center">
          <User className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">No Alumni Found</h3>
          <p className="text-gray-600">Try adjusting your search criteria.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredAlumni.map((member) => (
            <div key={member.id} className="bg-white rounded-xl shadow-sm border p-6 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center space-x-3">
                  <div className="w-12 h-12 bg-orange-600 rounded-full flex items-center justify-center">
                    {member.profilePicture ? (
                      <img src={member.profilePicture} alt={member.name} className="w-full h-full rounded-full object-cover" />
                    ) : (
                      <User className="h-6 w-6 text-white" />
                    )}
                  </div>
                  <div className="flex-1">
                    <h3 
                      className="font-semibold text-lg text-blue-600 hover:text-blue-800 cursor-pointer transition-colors"
                      onClick={() => handleViewProfile(member.id)}
                    >
                      {member.name}
                    </h3>
                    {member.currentJob && <p className="text-sm text-gray-700 font-medium">{member.currentJob}</p>}
                    {member.company && <p className="text-sm text-gray-600">{member.company}</p>}
                    {member.email && <p className="text-xs text-gray-500 mt-1">{member.email}</p>}
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-sm text-gray-600 mb-4">
                {member.location && (
                  <div className="flex items-center space-x-2">
                    <MapPin className="h-4 w-4" />
                    <span>{member.location}</span>
                  </div>
                )}
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4" />
                  <span>Class of {member.graduationYear}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Building className="h-4 w-4" />
                  <span>{member.department}</span>
                </div>
              </div>

              {member.isAvailableForMentorship && (
                <div className="flex items-center space-x-2 text-sm text-green-700 bg-green-50 px-3 py-1 rounded-lg mb-4">
                  <UserCheck className="h-4 w-4" />
                  <span>Available for Mentorship</span>
                </div>
              )}

              {/* Skills */}
              {member.skills && member.skills.length > 0 && (
                <div className="mb-4">
                  <div className="flex flex-wrap gap-1">
                    {member.skills.slice(0, 3).map((skill, index) => (
                      <span
                        key={index}
                        className="bg-orange-100 text-orange-800 px-2 py-1 rounded text-xs"
                      >
                        {skill}
                      </span>
                    ))}
                    {member.skills.length > 3 && (
                      <span className="bg-gray-100 text-gray-600 px-2 py-1 rounded text-xs">
                        +{member.skills.length - 3} more
                      </span>
                    )}
                  </div>
                </div>
              )}

              {/* Actions */}
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <div className="flex space-x-2">
                    {member.linkedinUrl && (
                      <a
                        href={member.linkedinUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:text-blue-700"
                      >
                        <Linkedin className="h-5 w-5" />
                      </a>
                    )}
                    {member.githubUrl && (
                      <a
                        href={member.githubUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-gray-800 hover:text-gray-900"
                      >
                        <Github className="h-5 w-5" />
                      </a>
                    )}
                  </div>

                  <button
                    onClick={() => handleViewProfile(member.id)}
                    className="px-3 py-1 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
                  >
                    View Profile
                  </button>
                </div>

                {member.isAvailableForMentorship && user?.role !== 'ALUMNI' && (
                  <button
                    onClick={() => handleRequestMentoring(member.id, member.name)}
                    className="w-full px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors text-sm flex items-center justify-center space-x-2"
                  >
                    <MessageCircle className="h-4 w-4" />
                    <span>Request Mentoring</span>
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Profile Modal */}
      {showProfile && selectedProfileId && (
        <UserProfile
          userId={selectedProfileId}
          userType="ALUMNI"
          onClose={handleCloseProfile}
        />
      )}
    </div>
  );
};

export default AlumniDirectory;