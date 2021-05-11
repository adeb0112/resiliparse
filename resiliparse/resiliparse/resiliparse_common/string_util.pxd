# Copyright 2021 Janek Bevendorff
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# distutils: language = c++

from libcpp.string cimport string
from resiliparse_inc.string_view cimport string_view
from resiliparse_inc.cctype cimport tolower


cdef extern from * nogil:
    """
    #include <cctype>

    /**
     * Strip leading white space from a C string.
     */
    inline size_t lstrip_c_str(const char** s_ptr, size_t l) {
        const char* end = *s_ptr + l;
        while (*s_ptr < end && std::isspace((*s_ptr)[0])) {
            ++(*s_ptr);
        }
        return end - *s_ptr;
    }

    /**
     * Strip trailing white space from a C string.
     */
    inline size_t rstrip_c_str(const char** s_ptr, size_t l) {
        const char* end = *s_ptr + l;
        while (end > *s_ptr && std::isspace((end - 1)[0])) {
            --end;
        }
        return end - *s_ptr;
    }
