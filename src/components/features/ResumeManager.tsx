import { Download, Edit, FileText, Plus, Save, Trash2, Upload, User, X } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useToast } from '../../contexts/ToastContext';
import { resumeAPI } from '../../services/api';

interface Resume {
  id: string;
  fileName: string;
  uploadedAt: string;
  isActive: boolean;
  skills?: string[];
  experiences?: Experience[];
  educations?: Education[];
  certifications?: string[];
  summary?: string;
  contactInfo?: ContactInfo;
}

interface Experience {
  company: string;
  position: string;
  duration: string;
  description: string;
  achievements?: string[];
}

interface Education {
  institution: string;
  degree: string;
  field: string;
  duration: string;
  grade?: string;
}

interface ContactInfo {
  email: string;
  phone: string;
  address: string;
  linkedin: string;
  github: string;
  portfolio: string;
}

const ResumeManager: React.FC = () => {
  const [resumes, setResumes] = useState<Resume[]>([]);
  const [currentResume, setCurrentResume] = useState<Resume | null>(null);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [editingResume, setEditingResume] = useState<Resume | null>(null);
  const [showUpload, setShowUpload] = useState(false);
  
  const { showToast } = useToast();

  useEffect(() => {
    loadResumes();
    loadCurrentResume();
  }, []);

  const loadResumes = async () => {
    try {
      const response = await resumeAPI.getMyResumes();
      setResumes(response);
    } catch (error: any) {
      showToast('Failed to load resumes', 'error');
    }
  };

  const loadCurrentResume = async () => {
    try {
      const response = await resumeAPI.getCurrentResume();
      setCurrentResume(response);
    } catch (error: any) {
      // No current resume is fine
    }
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validate file type
    const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    if (!allowedTypes.includes(file.type)) {
      showToast('Please upload a PDF, DOC, or DOCX file', 'error');
      return;
    }

    // Validate file size (10MB limit)
    if (file.size > 10 * 1024 * 1024) {
      showToast('File size must be less than 10MB', 'error');
      return;
    }

    setUploading(true);
    try {
      await resumeAPI.uploadResume(file);

      showToast('Resume uploaded successfully!', 'success');
      setShowUpload(false);
      loadResumes();
      loadCurrentResume();
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Failed to upload resume', 'error');
    } finally {
      setUploading(false);
    }
  };

  const activateResume = async (resumeId: string) => {
    try {
      await resumeAPI.activateResume(resumeId);
      showToast('Resume activated successfully!', 'success');
      loadResumes();
      loadCurrentResume();
    } catch (error: any) {
      showToast('Failed to activate resume', 'error');
    }
  };

  const deleteResume = async (resumeId: string) => {
    if (!confirm('Are you sure you want to delete this resume?')) return;
    
    try {
      await resumeAPI.deleteResume(resumeId);
      showToast('Resume deleted successfully!', 'success');
      loadResumes();
      loadCurrentResume();
    } catch (error: any) {
      showToast('Failed to delete resume', 'error');
    }
  };

  const downloadResume = async (resumeId: string, fileName: string) => {
    try {
      const blob = await resumeAPI.downloadResume(resumeId);

      const url = window.URL.createObjectURL(new Blob([blob]));
      const link = document.createElement('a');
      link.href = url;
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch (error: any) {
      showToast('Failed to download resume', 'error');
    }
  };

  const saveResumeData = async () => {
    if (!editingResume) return;

    try {
      await resumeAPI.updateResume(editingResume.id, editingResume);
      showToast('Resume data updated successfully!', 'success');
      setEditingResume(null);
      loadResumes();
      loadCurrentResume();
    } catch (error: any) {
      showToast('Failed to update resume data', 'error');
    }
  };

  const addSkill = () => {
    if (!editingResume) return;
    setEditingResume({
      ...editingResume,
      skills: [...(editingResume.skills || []), '']
    });
  };

  const updateSkill = (index: number, value: string) => {
    if (!editingResume) return;
    const skills = [...(editingResume.skills || [])];
    skills[index] = value;
    setEditingResume({ ...editingResume, skills });
  };

  const removeSkill = (index: number) => {
    if (!editingResume) return;
    const skills = editingResume.skills?.filter((_, i) => i !== index) || [];
    setEditingResume({ ...editingResume, skills });
  };

  const addExperience = () => {
    if (!editingResume) return;
    const newExperience: Experience = {
      company: '',
      position: '',
      duration: '',
      description: '',
      achievements: []
    };
    setEditingResume({
      ...editingResume,
      experiences: [...(editingResume.experiences || []), newExperience]
    });
  };

  const updateExperience = (index: number, field: keyof Experience, value: string) => {
    if (!editingResume) return;
    const experiences = [...(editingResume.experiences || [])];
    experiences[index] = { ...experiences[index], [field]: value };
    setEditingResume({ ...editingResume, experiences });
  };

  const removeExperience = (index: number) => {
    if (!editingResume) return;
    const experiences = editingResume.experiences?.filter((_, i) => i !== index) || [];
    setEditingResume({ ...editingResume, experiences });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <FileText className="h-6 w-6 text-orange-600" />
          <h2 className="text-xl font-semibold">Resume Manager</h2>
        </div>
        <button
          onClick={() => setShowUpload(true)}
          className="bg-orange-600 text-white px-4 py-2 rounded-lg hover:bg-orange-700 transition-colors flex items-center space-x-2"
        >
          <Upload className="h-5 w-5" />
          <span>Upload Resume</span>
        </button>
      </div>

      {/* Upload Modal */}
      {showUpload && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-md">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold">Upload Resume</h3>
              <button
                onClick={() => setShowUpload(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
            
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
              <Upload className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600 mb-4">
                Choose a resume file to upload
              </p>
              <p className="text-sm text-gray-400 mb-4">
                Supported formats: PDF, DOC, DOCX (Max 10MB)
              </p>
              <input
                type="file"
                onChange={handleFileUpload}
                accept=".pdf,.doc,.docx"
                disabled={uploading}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-orange-50 file:text-orange-700 hover:file:bg-orange-100"
              />
            </div>
            
            {uploading && (
              <div className="mt-4 text-center">
                <div className="inline-flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-orange-600"></div>
                  <span className="text-sm text-gray-600">Uploading...</span>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Current Resume */}
      {currentResume && (
        <div className="bg-white rounded-xl shadow-sm border p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold">Current Resume</h3>
            <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-sm font-medium">
              Active
            </span>
          </div>
          
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <FileText className="h-8 w-8 text-orange-600" />
              <div>
                <p className="font-medium">{currentResume.fileName}</p>
                <p className="text-sm text-gray-600">
                  Uploaded {new Date(currentResume.uploadedAt).toLocaleDateString()}
                </p>
              </div>
            </div>
            
            <div className="flex space-x-2">
              <button
                onClick={() => setEditingResume(currentResume)}
                className="p-2 text-gray-400 hover:text-blue-600 transition-colors"
              >
                <Edit className="h-4 w-4" />
              </button>
              <button
                onClick={() => downloadResume(currentResume.id, currentResume.fileName)}
                className="p-2 text-gray-400 hover:text-green-600 transition-colors"
              >
                <Download className="h-4 w-4" />
              </button>
            </div>
          </div>
          
          {/* Display resume data if available */}
          {currentResume.skills && currentResume.skills.length > 0 && (
            <div className="mt-4 pt-4 border-t border-gray-200">
              <h4 className="font-medium mb-2">Skills</h4>
              <div className="flex flex-wrap gap-2">
                {currentResume.skills.map((skill, index) => (
                  <span
                    key={index}
                    className="bg-blue-100 text-blue-800 px-2 py-1 rounded-lg text-sm"
                  >
                    {skill}
                  </span>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* All Resumes */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <h3 className="text-lg font-semibold mb-4">All Resumes</h3>
        
        {resumes.length === 0 ? (
          <div className="text-center py-8">
            <FileText className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No Resumes Uploaded</h3>
            <p className="text-gray-600">Upload your first resume to get started!</p>
          </div>
        ) : (
          <div className="space-y-4">
            {resumes.map((resume) => (
              <div
                key={resume.id}
                className={`border rounded-lg p-4 ${
                  resume.isActive ? 'border-green-200 bg-green-50' : 'border-gray-200'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <FileText className="h-6 w-6 text-orange-600" />
                    <div>
                      <p className="font-medium">{resume.fileName}</p>
                      <p className="text-sm text-gray-600">
                        Uploaded {new Date(resume.uploadedAt).toLocaleDateString()}
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center space-x-2">
                    {resume.isActive && (
                      <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium">
                        Active
                      </span>
                    )}
                    
                    <div className="flex space-x-1">
                      {!resume.isActive && (
                        <button
                          onClick={() => activateResume(resume.id)}
                          className="p-2 text-gray-400 hover:text-green-600 transition-colors"
                          title="Activate Resume"
                        >
                          <User className="h-4 w-4" />
                        </button>
                      )}
                      <button
                        onClick={() => setEditingResume(resume)}
                        className="p-2 text-gray-400 hover:text-blue-600 transition-colors"
                        title="Edit Resume Data"
                      >
                        <Edit className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => downloadResume(resume.id, resume.fileName)}
                        className="p-2 text-gray-400 hover:text-green-600 transition-colors"
                        title="Download"
                      >
                        <Download className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => deleteResume(resume.id)}
                        className="p-2 text-gray-400 hover:text-red-600 transition-colors"
                        title="Delete"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Edit Resume Data Modal */}
      {editingResume && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200 flex items-center justify-between">
              <h3 className="text-lg font-semibold">Edit Resume Data</h3>
              <button
                onClick={() => setEditingResume(null)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              {/* Summary */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Professional Summary
                </label>
                <textarea
                  value={editingResume.summary || ''}
                  onChange={(e) => setEditingResume({ ...editingResume, summary: e.target.value })}
                  rows={4}
                  className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                  placeholder="Brief professional summary..."
                />
              </div>

              {/* Skills */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="block text-sm font-medium text-gray-700">Skills</label>
                  <button
                    onClick={addSkill}
                    className="text-orange-600 hover:text-orange-700 text-sm font-medium flex items-center space-x-1"
                  >
                    <Plus className="h-4 w-4" />
                    <span>Add Skill</span>
                  </button>
                </div>
                <div className="space-y-2">
                  {(editingResume.skills || []).map((skill, index) => (
                    <div key={index} className="flex space-x-2">
                      <input
                        type="text"
                        value={skill}
                        onChange={(e) => updateSkill(index, e.target.value)}
                        className="flex-1 p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                        placeholder="Skill name"
                      />
                      <button
                        onClick={() => removeSkill(index)}
                        className="text-red-600 hover:text-red-700 p-2"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Experience */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="block text-sm font-medium text-gray-700">Experience</label>
                  <button
                    onClick={addExperience}
                    className="text-orange-600 hover:text-orange-700 text-sm font-medium flex items-center space-x-1"
                  >
                    <Plus className="h-4 w-4" />
                    <span>Add Experience</span>
                  </button>
                </div>
                <div className="space-y-4">
                  {(editingResume.experiences || []).map((exp, index) => (
                    <div key={index} className="border border-gray-200 rounded-lg p-4">
                      <div className="flex justify-between items-start mb-3">
                        <h4 className="font-medium">Experience {index + 1}</h4>
                        <button
                          onClick={() => removeExperience(index)}
                          className="text-red-600 hover:text-red-700"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <input
                          type="text"
                          value={exp.company}
                          onChange={(e) => updateExperience(index, 'company', e.target.value)}
                          placeholder="Company"
                          className="p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                        />
                        <input
                          type="text"
                          value={exp.position}
                          onChange={(e) => updateExperience(index, 'position', e.target.value)}
                          placeholder="Position"
                          className="p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                        />
                        <input
                          type="text"
                          value={exp.duration}
                          onChange={(e) => updateExperience(index, 'duration', e.target.value)}
                          placeholder="Duration (e.g., 2020-2022)"
                          className="p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                        />
                      </div>
                      <textarea
                        value={exp.description}
                        onChange={(e) => updateExperience(index, 'description', e.target.value)}
                        placeholder="Job description and responsibilities"
                        rows={3}
                        className="w-full mt-4 p-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500"
                      />
                    </div>
                  ))}
                </div>
              </div>
            </div>
            
            <div className="p-6 border-t border-gray-200 flex justify-end space-x-3">
              <button
                onClick={() => setEditingResume(null)}
                className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={saveResumeData}
                className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors flex items-center space-x-2"
              >
                <Save className="h-4 w-4" />
                <span>Save Changes</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ResumeManager;
